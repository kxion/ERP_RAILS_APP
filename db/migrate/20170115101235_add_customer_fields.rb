class AddCustomerFields < ActiveRecord::Migration
  def change
    add_column :customers, :discount_percent, :decimal
    add_column :customers, :credit_limit, :decimal
    add_column :customers, :tax_reference, :string
    add_column :customers, :payment_terms, :string
    add_column :customers, :customer_currency, :string
  end
end