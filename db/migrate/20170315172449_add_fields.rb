class AddFields < ActiveRecord::Migration
  def change
  	add_column :warehouse_location_items, :item_in_stock, :integer
  end
end
