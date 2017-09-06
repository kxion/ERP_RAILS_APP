class CreateSaleEvents < ActiveRecord::Migration
  def change
    create_table :sale_events do |t|
    	t.integer :account_id
    	t.integer :category_id
    	t.datetime :start_date
    	t.datetime :end_date
    	t.decimal :discount_percent

      t.timestamps null: false
    end
  end
end