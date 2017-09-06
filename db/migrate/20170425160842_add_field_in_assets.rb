class AddFieldInAssets < ActiveRecord::Migration
  def change
  	remove_column :assets, :warehouse_location_id
  	add_column :assets, :location, :string
  end
end
