class Customer < ActiveRecord::Base
  #Belongs To Relationship
  belongs_to :user
  
  #Has Many Relationship
  has_many :notes
  has_many :contacts, dependent: :destroy
  has_many :sales_orders, dependent: :destroy
  has_many :ledger_entries
  has_many :return_wizards
  has_many :cheque_registers

  #Validations
  validates :phone, presence: true

  #Scope For the Active Record
  scope :with_active, -> { where('is_active = ?', true) }

  #Creator,Updater to your ActiveRecord objects
  track_who_does_it

  #Constants
  TYPE = %w(Contractor Sales_Customer)

  def self.search_box(search_text,current_user_id)
     search = where("customers.sales_user_id = ?",current_user_id)
    if !/\A\d+\z/.match(search_text)
      code = search_text.gsub(/\D/,'')
      if code.present?
        search = search.where(id: code.to_i)
      else
        search = search.where("c_type LIKE :search OR phone LIKE :search
              OR country LIKE :search ", search: "%#{search_text}%")
      end
    else
      search = search.where("id :search", search: "%#{search_text}%")
    end
    return search
  end

  def self.search(params,current_user_id)
    search = where("customers.sales_user_id = ?",current_user_id)
    c_type = JSON.parse(params[:c_type]) if params[:c_type].present?
    search = search.where("customers.id = ?",params[:code].gsub(/\D/,'')) if params[:code].present?
    if params[:name].present?
      name = params[:name].downcase
      search = search.joins(:user)
      .where("(((lower(users.first_name) || ' ' || lower(users.last_name)) LIKE ?) "\
          'OR (lower(users.first_name) LIKE ?) OR (lower(users.last_name) LIKE ?))',\
          "%#{name}%", "%#{name}%", "%#{name}%")
    end
    search = search.where('customers.phone = ?',params[:phone]) if params[:phone].present?
    search = search.where('customers.country = ?',params[:country]) if params[:country].present?
    search = search.where('customers.c_type IN (?)',c_type) if c_type.present?
    search = search.where('customers.created_by_id = ?',params[:created_by_id]) if params[:created_by_id].present?
    search = search.where('DATE(customers.created_at) = ?', params[:created_at].to_date) if params[:created_at].present?
    return search
  end

  def self.sales_customers(current_user)
    where("customers.sales_user_id = ? AND customers.is_active = ?",current_user.id,true)
  end

  def get_json_customer_show
    customer_since = self.customer_since.present? ? self.customer_since.strftime('%d %B, %Y') : self.customer_since 
    as_json(only: [:id,:phone,:c_type,:street,:city,:state,:country,:postal_code,
      :decription,:discount_percent,:credit_limit,:tax_reference,:payment_terms,
      :customer_currency])
    .merge({
      code:"CUS#{self.id.to_s.rjust(4, '0')}",
      name:self.user.full_name,
      email:self.user.email,
      created_at:self.created_at.strftime('%d %B, %Y'),
      created_by:self.creator.try(:full_name),
      updated_at:self.updated_at.strftime('%d %B, %Y'),
      updated_by:self.updater.try(:full_name),
      notes:Note.with_active.get_json_notes(false,self.notes),
        contacts:Contact.with_active.get_json_contacts(false,self.contacts),
        customer_since: customer_since,
      })
  end  

  def get_json_customer_index
    as_json(only: [:id,:phone,:c_type,:country])
    .merge({name:self.user.full_name,
      created_at:self.created_at.strftime('%d %B, %Y'),
      created_by:self.creator.try(:full_name),
      })
  end 

  def self.get_json_customers
    customers_list =[]
    Customer.all.each do |customer|
      customers_list << customer.get_json_customer_index
    end
    return customers_list
  end

  def get_json_customer_edit
    created_at = self.created_at.present? ? self.created_at.strftime('%d %B, %Y') : self.created_at
    customer_since = self.customer_since.present? ? self.customer_since.strftime('%d %B, %Y') : self.customer_since 
    as_json(only: [])
    .merge({
      code:"CUS#{self.id.to_s.rjust(4, '0')}",
      id: self.user.id,
      email: self.user.email,
      first_name: self.user.first_name,
      last_name: self.user.last_name,
      customer_attributes:{
        id: self.id,
        phone: self.phone,
        c_type: self.c_type,
        street: self.street,
        city: self.city,
        state: self.state,
        country: self.country,
        postal_code: self.postal_code,
        decription: self.decription,
        discount_percent: self.discount_percent,
        credit_limit: self.credit_limit,
        tax_reference: self.tax_reference,
        payment_terms: self.payment_terms,
        customer_currency: self.customer_currency,
        created_at: created_at,
        customer_since:self.customer_since,
      }
    })
  end
end
