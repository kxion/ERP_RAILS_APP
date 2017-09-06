class CreatePurchaseOrders < ActiveRecord::Migration
    def change
        create_table :purchase_orders do |t|
            t.string :subject
            t.decimal :total_price #Unit Price  x  Quantity
            t.decimal :sub_total  #Autocalculated based on Order Items: Sum of all Item Total
            t.decimal :tax 
            t.decimal :grand_total #Autocalculated: Subtotal + Tax
            t.string :description
            t.integer :supplier_user_id

            t.integer :created_by_id
            t.integer :updated_by_id
            t.timestamps null: false
        end
    end
end
