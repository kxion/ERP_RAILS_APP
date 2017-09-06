class CreateMarketplaces < ActiveRecord::Migration
  def change
    create_table :marketplaces do |t|
      t.string :name
      t.string :url
      t.text :settings
      t.boolean :disabled
      t.string :api_uid
      t.boolean :has_api

      t.timestamps null: false
    end
  end
end
