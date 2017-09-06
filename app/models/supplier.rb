class Supplier < ActiveRecord::Base
  #Belongs To Relationship
  belongs_to :user

  #Has Many Relationship
  has_many :items, dependent: :destroy
  has_many :purchase_orders, class_name: "PurchaseOrder", foreign_key: "supplier_user_id"

  #Scope For the Active Record
  scope :with_active, -> { where('is_active = ?', true) }

  #Creator,Updater to your ActiveRecord objects
  track_who_does_it

  #Constants
  CURRENCY = %w(USD CAD AUD)

  def self.search_box(search_text,current_user_id)
    search = where("suppliers.sales_user_id = ?",current_user_id)
    if !/\A\d+\z/.match(search_text)
      code = search_text.gsub(/\D/,'')
      if code.present?
        search = search.where(id: code.to_i)
      else
        search = search.where("phone LIKE :search OR supplier_currency LIKE :search
              ", search: "%#{search_text}%")
      end
    else
      search = search.where("id :search", search: "%#{search_text}%")
    end
    return search
  end

  def self.search(params,current_user_id)
    search = where("suppliers.sales_user_id = ?",current_user_id)
    search = search.where("suppliers.id = ?",params[:code].gsub(/\D/,'')) if params[:code].present?
    search = search.where('suppliers.phone = ?',params[:phone]) if params[:phone].present?
    search = search.where('suppliers.supplier_currency = ?',params[:supplier_currency]) if params[:supplier_currency].present?
    search = search.where('DATE(suppliers.supplier_since) = ?', params[:supplier_since].to_date) if params[:supplier_since].present?
    search = search.joins(:user).where("lower(users.first_name) LIKE ?" ,"%#{params[:name].downcase}%") if params[:name].present?
    return search
  end

  def get_json_supplier
    supplier_since = self.supplier_since.present? ? self.supplier_since.strftime('%d %B, %Y') : self.supplier_since
    as_json(only: [:id,:phone,:country,:supplier_currency,:street,:city,:state,
      :postal_code])
    .merge({
      code:"SUP#{self.id.to_s.rjust(4, '0')}",
      name: self.user.first_name,
      email: self.user.email,
      supplier_since: supplier_since,
      created_at:self.created_at.strftime('%d %B, %Y'),
      created_by:self.creator.try(:full_name),
      updated_at:self.updated_at.strftime('%d %B, %Y'),
      updated_by:self.updater.try(:full_name),
      purchase_orders: self.purchase_orders.with_active.get_json_purchase_orders,
    })
  end 

  def self.get_json_suppliers
    suppliers_list =[]
    all.each do |supplier|
      suppliers_list << supplier.get_json_supplier
    end
    return suppliers_list
  end

  def get_json_supplier_edit
    as_json(only: [])
    .merge({
      id: self.user.id,
      email: self.user.email,
      first_name: self.user.first_name,
      supplier_attributes:{
        id: self.id,
        phone: self.phone,
        country: self.country,
        supplier_currency: self.supplier_currency,
        street: self.street,
        city: self.city,
        state: self.state,
        postal_code: self.postal_code,
        supplier_since: self.supplier_since,
      }
    })
  end 

  def self.sales_suppliers(current_user)
      where("suppliers.sales_user_id = ? AND suppliers.is_active = ?",current_user.id,true)
  end

  def self.get_json_suppliers_dropdown(suppliers)
    list = []
    suppliers.each do |supplier|
      list << as_json(only: [])
      .merge({name:supplier.user.first_name,
          supplier_id:supplier.id,
      })
    end
    return list
  end
end