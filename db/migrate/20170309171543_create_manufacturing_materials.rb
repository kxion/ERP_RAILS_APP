class CreateManufacturingMaterials < ActiveRecord::Migration
  def change
    create_table :manufacturing_materials do |t|
        t.integer :manufacturing_id
        t.integer :material_id
        t.integer :quantity
        t.decimal :total
        t.decimal :unit_price 

      t.timestamps null: false
    end
  end
end
