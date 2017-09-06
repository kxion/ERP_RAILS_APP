class CreateKnowledgeBases < ActiveRecord::Migration
    def change
        create_table :knowledge_bases do |t|
            t.string :title
            t.integer :kb_category_id
            t.string :status
            t.integer :revision
            t.text :body
            t.text :resolution
            t.integer :author_id
            t.integer :approver_id

            t.integer :sales_user_id
            t.boolean :is_active, default: true
            t.integer :created_by_id
            t.integer :updated_by_id
            t.timestamps null: false
        end
    end
end









