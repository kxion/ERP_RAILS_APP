class CreateInventoryItems < ActiveRecord::Migration
  def change
    create_table :inventory_items do |t|
      t.string :icc
      t.string :serial
      t.string :make
      t.string :model
      t.integer :item_category_id
      t.integer :item_source_id
      t.string :status
      t.string :location
      t.text :notes
      t.decimal :acquisition_cost, :precision => 16, :scals => 2
      t.decimal :cached_profit_share_percent, :precision => 8, :scals => 2
      t.text :details
      t.boolean :archived
      t.string :check_value
      t.string :item_category_name
      t.integer :listing_id

      t.timestamps null: false
    end
  end
end
