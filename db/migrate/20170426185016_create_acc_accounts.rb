class CreateAccAccounts < ActiveRecord::Migration
  def change
    create_table :acc_accounts do |t|
      t.string :acc_code
      t.string :name
      t.string :acc_type
      t.text :description
      
      t.boolean :is_active, default: true
      t.integer :sales_user_id
      t.integer :created_by_id
      t.integer :updated_by_id
      t.timestamps null: false
    end
  end
end