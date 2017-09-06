class AddOmStatusFields < ActiveRecord::Migration
  def change
    add_column :sales_orders, :status, :string
  end
end
