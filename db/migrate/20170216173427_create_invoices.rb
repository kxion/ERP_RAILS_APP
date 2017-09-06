class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
        t.integer :customer_user_id
        t.integer :contact_user_id
        t.integer :sales_order_id
        t.string :name
        t.decimal :subtotal
        t.decimal :tax
        t.decimal :grand_total
        t.integer :account_id
        t.string :uid
        t.integer :buyer_id
        t.integer :order_shipping_detail_id
        t.string :payment_status
        t.datetime :paid_at
        t.datetime :refunded_at
        t.boolean :shipped
        t.datetime :shipped_at
        t.boolean :cancelled
        t.datetime :cancelled_at
        t.string :cancel_reason
        t.text :notes
        t.string :payment_method
        t.datetime :create_timestamp
        t.datetime :update_timestamp
        t.decimal :discount, :precision => 16, :scale => 4
        t.decimal :marketplace_fee, :precision => 10, :scale => 2
        t.decimal :processing_fee, :precision => 10, :scale => 2
        t.string :status
        t.integer :sales_user_id
        t.boolean :is_active, default: true
        t.boolean :is_invoice_active, default: true

        t.decimal :acquisition_cost, :precision => 10, :scale => 2
        t.decimal :profit_share_deductions, :precision => 10, :scale => 2
        t.decimal :net, :precision => 10, :scale => 2

        t.integer :created_by_id
        t.integer :updated_by_id
        t.timestamps null: false
    end

    add_column :sales_order_items, :invoice_id, :integer

  end
end
