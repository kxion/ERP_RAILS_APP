class AddOmFields < ActiveRecord::Migration
  def change
  	add_column :sales_orders, :account_id, :integer
  	add_column :sales_orders, :uid, :string
    add_column :sales_orders, :buyer_id, :integer
    add_column :sales_orders, :order_shipping_detail_id, :integer
    add_column :sales_orders, :payment_status, :string
    add_column :sales_orders, :paid_at, :datetime
    add_column :sales_orders, :refunded_at, :datetime
    add_column :sales_orders, :shipped, :boolean
    add_column :sales_orders, :shipped_at, :datetime
    add_column :sales_orders, :cancelled, :boolean
    add_column :sales_orders, :cancelled_at, :datetime
    add_column :sales_orders, :cancel_reason, :string
    add_column :sales_orders, :notes, :text
    add_column :sales_orders, :payment_method, :string
    add_column :sales_orders, :create_timestamp, :datetime
    add_column :sales_orders, :update_timestamp, :datetime
    add_column :sales_orders, :discount, :decimal, :precision => 16, :scale => 4
    add_column :sales_orders, :marketplace_fee, :decimal, :precision => 10, :scale => 2
    add_column :sales_orders, :processing_fee, :decimal, :precision => 10, :scale => 2
  end
end
