class CreateWarehouses < ActiveRecord::Migration
    def change
        create_table :warehouses do |t|
            t.string :subject
            t.string :city
            t.string :province
            t.string :country
            t.string :description
            t.integer :postalcode
            t.string :street

            t.integer :sales_user_id
            t.boolean :is_active, default: true
            t.integer :created_by_id
            t.integer :updated_by_id
            t.timestamps null: false
        end
    end
end
