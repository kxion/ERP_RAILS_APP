class AddIsActiveInvoiceFields < ActiveRecord::Migration
  def change
  	add_column :sales_orders, :is_invoice_active, :boolean, default: true
  end
end
