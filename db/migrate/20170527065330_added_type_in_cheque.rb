class AddedTypeInCheque < ActiveRecord::Migration
  def change
  	add_column :cheque_registers, :rate, :decimal
  	add_column :cheque_registers, :rate_type, :string
  end
end
