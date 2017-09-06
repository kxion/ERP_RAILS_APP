class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
        t.integer :user_id
		t.string :salutation 
		t.datetime :date_of_birth 
		t.string :gender 
		t.string :b_group 
		t.string :nationality 
		t.string :designation 
		t.string :department 
		t.string :e_type 
		t.string :work_shift 
		t.string :reporting_person 
		t.datetime :date_of_joining 
		t.boolean :allow_login 
		t.string :religion 
		t.string :marital_status 
		t.string :mobile 
		t.string :phone_office 
		t.string :phone_home 
		t.string :permanent_address_street 
		t.string :permanent_address_city 
		t.string :permanent_address_state 
		t.integer :permanent_address_postalcode 
		t.string :permanent_address_country 
		t.string :resident_address_street 
		t.string :resident_address_city 
		t.string :resident_address_state 
		t.integer :resident_address_postalcode 
		t.string :resident_address_country

        t.integer :sales_user_id
        t.boolean :is_active, default: true
        
        t.integer :created_by_id
        t.integer :updated_by_id
        t.timestamps null: false
    end
  end
end
