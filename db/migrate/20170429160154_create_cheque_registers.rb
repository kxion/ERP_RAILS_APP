class CreateChequeRegisters < ActiveRecord::Migration
  def change
    create_table :cheque_registers do |t|
      t.string :payee
      t.date :cheque_date
      t.decimal :debit
      t.decimal :credit
      t.text :notes
      t.string :status

      t.boolean :is_active, default: true
      t.integer :sales_user_id
      t.integer :created_by_id
      t.integer :updated_by_id
      t.timestamps null: false
    end
  end
end