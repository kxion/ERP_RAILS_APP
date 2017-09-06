class AddDefaultAccountField < ActiveRecord::Migration
  def change
  	add_column :acc_accounts, :default_type, :string
  end
end
