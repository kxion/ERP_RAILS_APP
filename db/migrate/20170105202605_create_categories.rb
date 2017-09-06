class CreateCategories < ActiveRecord::Migration
    def change
        create_table :categories do |t|
            t.string :name
            t.string :unit
            t.decimal :tax
            t.string :manufacturer
            t.string :description

            t.integer :created_by_id
            t.integer :updated_by_id
            t.timestamps null: false
        end
    end
end
# Need to add Image
