class AddEmailFieldInUser < ActiveRecord::Migration
  def change
  	add_column :users, :email, :string, null: false, default: ""
  end
end
