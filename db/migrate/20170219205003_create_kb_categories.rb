class CreateKbCategories < ActiveRecord::Migration
    def change
        create_table :kb_categories do |t|
            t.string :name
            t.string :description

            t.integer :sales_user_id
            t.boolean :is_active, default: true
            t.integer :created_by_id
            t.integer :updated_by_id
            t.timestamps null: false
        end
    end
end