class CreateItems < ActiveRecord::Migration
    def change
        create_table :items do |t|
            t.string :name
            t.integer :category_id
            t.integer :supplier_id
            t.string :unit
            t.decimal :tax
            t.integer :item_in_stock
            t.integer :max_level
            t.integer :min_level
            t.decimal :selling_price   
            t.decimal :purchase_price
            t.string :item_description
            t.string :purchase_description
            t.string :selling_description
            t.string :selling_description
            
            t.integer :created_by_id
            t.integer :updated_by_id
            t.timestamps null: false
        end
    end
end
