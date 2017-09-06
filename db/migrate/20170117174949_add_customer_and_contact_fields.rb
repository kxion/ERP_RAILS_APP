class AddCustomerAndContactFields < ActiveRecord::Migration
  def change
    add_column :contacts, :sales_user_id, :integer
    add_column :customers, :sales_user_id, :integer
  end
end
