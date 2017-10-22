class CreateItemSources < ActiveRecord::Migration
  def change
    create_table :item_sources do |t|
      t.string :name
      t.string :short_name
      t.decimal :profit_share_percent, :precision => 8, :scale => 2

      t.timestamps null: false
    end
  end
end
