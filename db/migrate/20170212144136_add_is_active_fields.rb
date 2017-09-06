class AddIsActiveFields < ActiveRecord::Migration
  def change
  	add_column :accounts, :is_connected, :boolean, default: false

  	add_column :categories, :is_active, :boolean, default: true
  	add_column :contacts, :is_active, :boolean, default: true
  	add_column :customers, :is_active, :boolean, default: true
  	add_column :items, :is_active, :boolean, default: true
  	add_column :notes, :is_active, :boolean, default: true
  	add_column :purchase_orders, :is_active, :boolean, default: true
  	add_column :sales_orders, :is_active, :boolean, default: true
  	add_column :suppliers, :is_active, :boolean, default: true
  	add_column :warehouse_locations, :is_active, :boolean, default: true  	
  end
end
