class CreateManufacturingHistories < ActiveRecord::Migration
  def change
    create_table :manufacturing_histories do |t|
        t.string :subject
        t.string :description
        t.string :status
        t.string :m_type
        t.integer :quantity
        t.integer :item_id
        t.integer :sales_order_id
        t.date :start_date
        t.date :expected_completion_date
      	t.integer :manufacturing_id

        t.integer :sales_user_id
        t.boolean :is_active, default: true
        t.integer :created_by_id
        t.integer :updated_by_id
        t.timestamps null: false
    end
  end
end
