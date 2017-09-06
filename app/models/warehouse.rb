class Warehouse < ActiveRecord::Base
  #Has Many Relationship
  has_many :warehouse_locations
  
  #Creator,Updater to your ActiveRecord objects
  track_who_does_it

  #Scope For the Active Record
  scope :with_active, -> { where('is_active = ?', true) }

  def self.search_box(search_text,current_user_id)
    search = where("warehouses.sales_user_id = ?",current_user_id)
    if !/\A\d+\z/.match(search_text)
      code = search_text.gsub(/\D/,'')
      if code.present?
        search = search.where(id: code.to_i)
      else
        search = search.where("lower(subject) LIKE :search OR lower(city) LIKE :search
          OR lower(province) LIKE :search OR lower(country) LIKE :search
          OR lower(description) LIKE :search OR lower(street) LIKE :search ", search: "%#{search_text.downcase}%")
      end
    else
      search = search.where("postalcode = ?", search_text)
    end
    return search
  end

  def self.search(params,current_user_id)
    search = where("warehouses.sales_user_id = ?",current_user_id)
    search = search.where("warehouses.id = ?",params[:code].gsub(/\D/,'')) if params[:code].present?
    search = search.where('warehouses.subject = ?',params[:subject]) if params[:subject].present?
    search = search.where('warehouses.city = ?',params[:city]) if params[:city].present?
    search = search.where('warehouses.province = ?',params[:province]) if params[:province].present?
    search = search.where('warehouses.country = ?',params[:country]) if params[:country].present?
    search = search.where('warehouses.description = ?',params[:description]) if params[:description].present?
    search = search.where('warehouses.street = ?',params[:street]) if params[:street].present?
    search = search.where('warehouses.postalcode = ?',params[:postalcode]) if params[:postalcode].present?
    search = search.where('DATE(warehouses.created_at) = ?', params[:created_at].to_date) if params[:created_at].present?
    search = search.where('warehouses.created_by_id = ?',params[:created_by_id]) if params[:created_by_id].present?
    return search
  end

  def get_json_warehouse
    as_json(only: [:id, :subject, :city, :province, :country, :description, :street, :postalcode])
    .merge({
      code:"WH#{self.id.to_s.rjust(4, '0')}",
      created_at:self.created_at.strftime('%d %B, %Y'),
      created_by:self.creator.try(:full_name),
      updated_at:self.updated_at.strftime('%d %B, %Y'),
      updated_by:self.updater.try(:full_name),
        warehouse_locations: self.warehouse_locations.with_active.get_json_warehouse_locations
    })
  end 

  def self.get_json_warehouses
    warehouses_list =[]
    all.each do |warehouse|
      warehouses_list << warehouse.get_json_warehouse
    end
    return warehouses_list
  end

  def self.sales_warehouses(current_user)
    where("warehouses.sales_user_id = ? AND warehouses.is_active = ?",current_user.id,true)
  end

  def self.get_json_warehouses_dropdown(warehouses)
    list = []
    warehouses.each do |warehouse|
      list << as_json(only: [])
      .merge({name:warehouse.subject,
        warehouse_id:warehouse.id,
      })
    end
    return list
  end
end