class ManufacturingMaterial < ActiveRecord::Base
  #Belongs To Relationship
  belongs_to :material
  belongs_to :manufacturing
  
  #After Create Call Function
  after_create :decrease_material_quantity

  def get_json_manufacturing_material
    as_json(only: [:id,:manufacturing_id, :material_id, :quantity, :total, :unit_price])
    .merge({
      code:"MAT#{self.material_id.to_s.rjust(4, '0')}",
      name:self.material.try(:name),
    })
  end 

  def self.get_json_manufacturing_materials
    manufacturing_materials_list =[]
    all.each do |manufacturing_material|
      manufacturing_materials_list << manufacturing_material.get_json_manufacturing_material
    end
    return manufacturing_materials_list
  end

  def decrease_material_quantity
    self.material.update_attributes(quantity: self.material.quantity - self.quantity)
  end
end