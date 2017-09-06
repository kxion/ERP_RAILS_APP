class CreateLedgerEntries < ActiveRecord::Migration
  def change
    create_table :ledger_entries do |t|
      t.string :subject
      t.integer :customer_id
      t.integer :acc_account_id
      t.integer :invoice_id
      t.decimal :amount

      t.boolean :is_active, default: true
      t.integer :sales_user_id
      t.integer :created_by_id
      t.integer :updated_by_id
      t.timestamps null: false
    end
  end
end