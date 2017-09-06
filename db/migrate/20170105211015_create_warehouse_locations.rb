class CreateWarehouseLocations < ActiveRecord::Migration
    def change
        create_table :warehouse_locations do |t|
            t.string :subject
            t.integer :row_no
            t.string :warehouse
            t.string :status
            t.string :description
            t.integer :rack_from
            t.integer :rack_to

            t.integer :created_by_id
            t.integer :updated_by_id
            t.timestamps null: false
        end
    end
end
