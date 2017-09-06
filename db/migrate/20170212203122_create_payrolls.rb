class CreatePayrolls < ActiveRecord::Migration
  def change
    create_table :payrolls do |t|
		t.string :subject
		t.integer :employee_id
		t.decimal :base_pay
		t.decimal :allowances
		t.decimal :deductions
		t.decimal :expenses
		t.decimal :tax
		t.decimal :total

        t.integer :sales_user_id
        t.boolean :is_active, default: true
        
        t.integer :created_by_id
        t.integer :updated_by_id
        t.timestamps null: false
    end
  end
end


