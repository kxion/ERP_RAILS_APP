class CreateItemCategories < ActiveRecord::Migration
  def change
    create_table :item_categories do |t|
      t.string :title
      t.integer :parent_category_id

      t.timestamps
    end
  end
end
