class AddNoteFields < ActiveRecord::Migration
  def change
    add_column :notes, :contact_id, :integer
    add_column :notes, :customer_id, :integer
    add_column :notes, :sales_user_id, :integer
  end
end
