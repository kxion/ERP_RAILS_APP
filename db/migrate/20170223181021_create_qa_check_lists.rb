class CreateQaCheckLists < ActiveRecord::Migration
  def change
    create_table :qa_check_lists do |t|
      t.string :name
      t.integer :manufacturing_id
      t.boolean :passed

      t.timestamps null: false
    end
  end
end
