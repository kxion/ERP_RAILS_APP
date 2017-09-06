class CreateSalesOrders < ActiveRecord::Migration
    def change
        create_table :sales_orders do |t|
            t.integer :customer_user_id
            t.integer :contact_user_id
            t.string :name
            t.decimal :subtotal
            t.decimal :tax
            t.decimal :grand_total
            
            t.integer :created_by_id
            t.integer :updated_by_id
            t.timestamps null: false
        end
    end
end


