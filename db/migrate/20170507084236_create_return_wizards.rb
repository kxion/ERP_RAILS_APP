class CreateReturnWizards < ActiveRecord::Migration
  def change
    create_table :return_wizards do |t|
      t.string :subject
      t.integer :invoice_id
      t.integer :customer_id
      t.decimal :original_amount
      t.decimal :shipping_charges
      t.decimal :amount_to_be_refunded
      t.string :refund_type
      t.string :payment_type
      t.datetime :date_paid
      t.string :status
      t.string :reason_for_return
      t.text :return_description

      t.boolean :is_active, default: true
      t.integer :sales_user_id
      t.integer :created_by_id
      t.integer :updated_by_id
      t.timestamps null: false
    end
  end
end