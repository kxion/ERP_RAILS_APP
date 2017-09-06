class CreateMaintananceSchedules < ActiveRecord::Migration
  def change
    create_table :maintanance_schedules do |t|
      t.string :subject
      t.datetime :schedule_date
      t.integer :asset_id
      t.string :status
      t.text :description

      t.boolean :is_active, default: true
      t.integer :sales_user_id
      t.integer :created_by_id
      t.integer :updated_by_id
      t.timestamps null: false
    end
  end
end