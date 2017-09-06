class ReportExpensesController < ApplicationController

  def index
    if params[:search_text].present?
      expenses = Expense.search_box(params[:search_text],current_user.id).with_active.get_json_expenses
    else
      expenses = Expense.report_search(params,current_user.id).with_active.get_json_expenses
    end
    render status: 200, json: expenses.as_json
  end
end
