class Material < ActiveRecord::Base
  #Belongs To Relationship
  belongs_to :manufacturing
  
  #Has Many Relationship
  has_many :manufacturing_materials

  #Scope For the Active Record
  scope :with_active, -> { where('is_active = ?', true) }
  
  #Creator,Updater to your ActiveRecord objects
  track_who_does_it

  def self.search_box(search_text,current_user_id)
    search = where("materials.sales_user_id = ?",current_user_id)
    if !/\A\d+\z/.match(search_text)
      code = search_text.gsub(/\D/,'')
      if code.present?
        search = search.where(id: code.to_i)
      else
        search = search.where("name LIKE :search OR description LIKE :search", search: "%#{search_text}%")
      end
    else
      search = search.where("unit = ? OR quantity = ? OR price = ?", search_text, search_text, search_text)
    end
    return search
  end

  def self.search(params,current_user_id)
    search = where("materials.sales_user_id = ?",current_user_id)
    search = search.where("materials.id = ?",params[:code].gsub(/\D/,'')) if params[:code].present?
    search = search.where('materials.name = ?',params[:name]) if params[:name].present?
    search = search.where('materials.unit = ?',params[:unit]) if params[:unit].present?
    search = search.where('materials.quantity = ?',params[:quantity]) if params[:quantity].present?
    search = search.where('materials.description = ?',params[:description]) if params[:description].present?
    search = search.where('materials.price = ?',params[:price]) if params[:price].present?
    search = search.where('materials.manufacturing_id = ?',params[:manufacturing_id]) if params[:manufacturing_id].present?
    search = search.where('DATE(materials.created_at) = ?', params[:created_at].to_date) if params[:created_at].present?
    search = search.where('materials.created_by_id = ?',params[:created_by_id]) if params[:created_by_id].present?
    return search
  end

  def get_json_material
    as_json(only: [:id, :manufacturing_id, :name, :description, :unit, :quantity, :price])
    .merge({
      code:"MAT#{self.id.to_s.rjust(4, '0')}",
      created_at:self.created_at.strftime('%d %B, %Y'),
      created_by:self.creator.try(:full_name),
      updated_at:self.updated_at.strftime('%d %B, %Y'),
      updated_by:self.updater.try(:full_name),
      manufacturing:self.manufacturing.try(:subject),
    })
  end 

  def self.get_json_materials
    materials_list =[]
    all.each do |material|
      materials_list << material.get_json_material
    end
    return materials_list
  end

  def self.sales_materials(current_user)
    where("materials.sales_user_id = ? AND materials.is_active = ?",current_user.id,true)
  end

  def self.get_json_materials_dropdown(materials)
    list = []
    materials.each do |material|
      list << as_json(only: [])
      .merge({name:material.name,
        material_id:material.id,
        unit:material.unit,
        quantity:material.quantity,
      })
    end
    return list
  end 
end