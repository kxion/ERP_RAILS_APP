class ReportPayrollsController < ApplicationController

  def index
    if params[:search_text].present?
      payrolls = Payroll.search_box(params[:search_text],current_user.id).with_active.get_json_payrolls
    else
      payrolls = Payroll.report_search(params,current_user.id).with_active.get_json_payrolls
    end
    render status: 200, json: payrolls.as_json
  end
end
