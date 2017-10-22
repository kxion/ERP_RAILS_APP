class CreateListings < ActiveRecord::Migration
  def change
    create_table :listings do |t|
      t.integer :user_id
      t.integer :item_category_id
      t.string :title
      t.string :make
      t.string :model
      t.text :description
      t.integer :shipping_preset_id
      t.datetime :publish_on
      t.decimal :cost, :precision => 16, :scale => 4

      t.timestamps null: false
    end
  end
end
