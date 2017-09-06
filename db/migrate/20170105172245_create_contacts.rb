class CreateContacts < ActiveRecord::Migration
    def change
        create_table :contacts do |t|
            t.integer :user_id
            t.integer :customer_id
            t.string :phone_mobile
            t.string :phone_work
            t.string :designation
            t.string :salutation
            t.string :department

            t.string :primary_street
            t.string :primary_city
            t.string :primary_state
            t.string :primary_country
            t.string :primary_postal_code

            t.string :alternative_street
            t.string :alternative_city
            t.string :alternative_state
            t.string :alternative_country
            t.string :alternative_postal_code

            t.integer :created_by_id
            t.integer :updated_by_id
            t.timestamps null: false
        end
    end
end

