class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :title
      t.integer :user_id
      t.integer :marketplace_id
      t.string :auto_renew
      t.text :relisting_pricing
      t.text :state

      t.timestamps null: false
    end
  end
end
