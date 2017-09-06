class AddSalesUserIdFields < ActiveRecord::Migration
  def change
  	add_column :categories, :sales_user_id, :integer
  	add_column :items, :sales_user_id, :integer
  	add_column :purchase_orders, :sales_user_id, :integer
  	add_column :sales_orders, :sales_user_id, :integer
  	add_column :suppliers, :sales_user_id, :integer
  end
end
