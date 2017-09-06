class CreatePurchaseOrderItems < ActiveRecord::Migration
    def change
        create_table :purchase_order_items do |t|
            t.integer :purchase_order_id
            t.integer :item_id
            t.integer :quantity
            t.decimal :total
            t.decimal :unit_price 
            t.decimal :discount 
            t.decimal :item_total #Auto Calculated: Total - Discount
            
            t.timestamps null: false
        end
    end
end
