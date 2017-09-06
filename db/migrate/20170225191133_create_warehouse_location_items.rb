class CreateWarehouseLocationItems < ActiveRecord::Migration
  def change
    create_table :warehouse_location_items do |t|
    	t.integer :warehouse_location_id
    	t.integer :item_id

      	t.integer :created_by_id
     	t.integer :updated_by_id
      	t.timestamps null: false
    end
  end
end
