class CreateNotes < ActiveRecord::Migration
    def change
        create_table :notes do |t|
            t.string :subject
            t.string :decription
              
            t.integer :created_by_id
            t.integer :updated_by_id
            t.timestamps null: false
        end
    end
end
