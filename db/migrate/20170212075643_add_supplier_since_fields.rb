class AddSupplierSinceFields < ActiveRecord::Migration
  def change
  	add_column :suppliers, :supplier_since, :datetime  	
  end
end
