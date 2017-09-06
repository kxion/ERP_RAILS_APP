class AddCustomerFieldInChqueRegister < ActiveRecord::Migration
  def change
  	add_column :cheque_registers, :customer_id, :integer
  end
end
