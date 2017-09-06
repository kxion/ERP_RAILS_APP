class PayrollsController < ApplicationController
  before_action :set_payroll, only: [:show, :update]
  before_action :set_delete_all_payroll, only: [:delete_all]

  def index
    if params[:search_text].present?
      payrolls = Payroll.search_box(params[:search_text],current_user.id).with_active.get_json_payrolls
    else
      payrolls = Payroll.search(params,current_user.id).with_active.get_json_payrolls
    end
    render status: 200, json: payrolls.as_json
  end

  def show
    render status: 200, json: @payroll.get_json_payroll.as_json  
  end

  def create
    payroll = Payroll.new(payroll_params)
    payroll.sales_user_id = current_user.id
    if payroll.save
      render status: 200, json: { payroll_id: payroll.id}
    else
      render status: 200, json: { message: payroll.errors.full_messages.first }
    end
  end 

  def update
    if @payroll.update_attributes(payroll_params)
      render status: 200, json: { payroll_id: @payroll.id}
    else
      render status: 200, json: { message: @payroll.errors.full_messages.first }
    end
  end

  def delete_all
    @payroll_ids.each do |id|
      payroll = Payroll.find(id.to_i)
      payroll.update_attribute(:is_active, false)
    end
    render json: {status: :ok}
  end

  private
    def set_payroll
      @payroll = Payroll.find(params[:id])
    end

    def set_delete_all_payroll
      @payroll_ids = JSON.parse(params[:ids])
    end

    def payroll_params
      params.require(:payroll).permit(:id, :subject, :employee_id, :base_pay,
       :allowances, :deductions, :expenses, :tax, :total)
    end
end