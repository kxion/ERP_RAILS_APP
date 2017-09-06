class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.string :subject
      t.string :status
      t.string :category
      t.integer :warehouse_location_id
      t.text :description

      t.boolean :is_active, default: true
      t.integer :sales_user_id
      t.integer :created_by_id
      t.integer :updated_by_id
      t.timestamps null: false
    end
  end
end