class CreateSuppliers < ActiveRecord::Migration
    def change
        create_table :suppliers do |t|
            t.integer :user_id
            t.string :phone
            t.string :country
            t.string :supplier_currency
            t.string :street
            t.string :city
            t.string :state
            t.string :country
            t.string :postal_code

            t.integer :created_by_id
            t.integer :updated_by_id
            t.timestamps null: false
        end
    end
end

