class AddCustomerSinceFields < ActiveRecord::Migration
  def change
    add_column :customers, :customer_since, :date
  end
end
