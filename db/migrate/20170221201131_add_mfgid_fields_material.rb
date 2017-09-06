class AddMfgidFieldsMaterial < ActiveRecord::Migration
  def change
  	add_column :materials, :manufacturing_id, :integer
  end
end
