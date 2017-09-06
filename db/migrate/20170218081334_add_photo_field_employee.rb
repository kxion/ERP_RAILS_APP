class AddPhotoFieldEmployee < ActiveRecord::Migration
  def change
  	add_column :employees, :photo, :string
  end
end
