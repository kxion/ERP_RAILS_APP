class ExpensesController < ApplicationController
  before_action :set_expense, only: [:show, :update, :delete_all]
  before_action :set_delete_all_expense, only: [:_delete_all]

  def index
    if params[:search_text].present?
      expenses = Expense.search_box(params[:search_text],current_user.id).with_active.get_json_expenses
    else
      expenses = Expense.search(params,current_user.id).with_active.get_json_expenses
    end
    render status: 200, json: expenses.as_json
  end

  def show
    render status: 200, json: @expense.get_json_expense.as_json    
  end

  def create
    expense = Expense.new(expense_params)
    expense.sales_user_id = current_user.id
    if expense.save
      render status: 200, json: { expense_id: expense.id}
    else
      render status: 200, json: { message: expense.errors.full_messages.first }
    end
  end 

  def update
    if @expense.update_attributes(expense_params)
      render status: 200, json: { expense_id: @expense.id}
    else
      render status: 200, json: { message: @expense.errors.full_messages.first }
    end
  end

  def delete_all
    @expense_ids.each do |id|
      expense = Expense.find(id.to_i)
      expense.update_attribute(:is_active, false)
    end
    render json: {status: :ok}
  end

  private
    def set_expense
      @expense = Expense.find(params[:id])
    end

    def set_delete_all_expense
      @expense_ids = JSON.parse(params[:ids])
    end

    def expense_params
      params.require(:expense).permit(:id, :subject, :employee_id, :amount, :status)
    end
end