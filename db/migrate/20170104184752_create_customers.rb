class CreateCustomers < ActiveRecord::Migration
    def change
        create_table :customers do |t|
            t.integer :user_id
            t.string :phone
            t.string :c_type
            t.string :street
            t.string :city
            t.string :state
            t.string :country
            t.string :postal_code
            t.string :decription
            
            t.integer :created_by_id
            t.integer :updated_by_id
            t.timestamps null: false
        end
    end
end