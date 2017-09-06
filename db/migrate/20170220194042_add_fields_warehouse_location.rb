class AddFieldsWarehouseLocation < ActiveRecord::Migration
  	def change
  		remove_column :warehouse_locations, :warehouse, :string
  		add_column :warehouse_locations, :warehouse_id, :integer
  		add_column :warehouse_locations, :sales_user_id, :integer
  		add_column :warehouse_locations, :asset, :string
  		add_column :warehouse_locations, :sku, :string
  	end
end
