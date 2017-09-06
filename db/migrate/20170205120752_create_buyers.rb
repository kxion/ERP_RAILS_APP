class CreateBuyers < ActiveRecord::Migration
  def change
    create_table :buyers do |t|
      t.string :email
      t.string :uid
      t.integer :marketplace_id
      t.string :name
      t.string :phone_number

      t.timestamps null: false
    end
  end
end
