class AddContactFields < ActiveRecord::Migration
  def change
    add_column :contacts, :decription, :text
    add_column :contacts, :company, :string
  end
end