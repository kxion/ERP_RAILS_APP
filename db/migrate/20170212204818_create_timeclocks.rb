class CreateTimeclocks < ActiveRecord::Migration
  def change
    create_table :timeclocks do |t|
        t.string :subject
        t.integer :employee_id
        t.time :in_time
        t.time :out_time

        t.integer :sales_user_id
        t.boolean :is_active, default: true

        t.integer :created_by_id
        t.integer :updated_by_id
        t.timestamps null: false
    end
  end
end
