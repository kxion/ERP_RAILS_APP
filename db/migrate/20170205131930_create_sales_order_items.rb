class CreateSalesOrderItems < ActiveRecord::Migration
  def change
    create_table :sales_order_items do |t|
    	t.integer :sales_order_id
    	t.decimal :item_price,         precision: 16, scale: 4
    	t.integer :quantity
    	t.string :uid

        t.timestamps null: false
    end
  end
end
