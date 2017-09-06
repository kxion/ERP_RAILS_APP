class ChequeRegistersController < ApplicationController

  before_action :set_cheque_register, only: [:show, :update]
  before_action :set_delete_all_cheque_register, only: [:delete_all]

  def index
    if params[:search_text].present?
      cheque_registers = ChequeRegister.search_box(params[:search_text],current_user.id).with_active.get_json_cheque_registers
    else
      cheque_registers = ChequeRegister.search(params,current_user.id).with_active.get_json_cheque_registers
    end
    render status: 200, json: cheque_registers.as_json
  end

  def show
    render status: 200, json: @cheque_register.get_json_cheque_register.as_json   
  end

  def create
    cheque_register = ChequeRegister.new(cheque_register_params)
    cheque_register.sales_user_id = current_user.id
    if cheque_register.save
      render status: 200, json: { cheque_register_id: cheque_register.id }
    else
      render status: 200, json: { message: cheque_register.errors.full_messages.first }
    end
  end 

  def update
    if @cheque_register.update_attributes(cheque_register_params)
      render status: 200, json: { cheque_register_id: @cheque_register.id }
    else
      render status: 200, json: { message: @cheque_register.errors.full_messages.first }
    end
  end

  def delete_all
    @cheque_register_ids.each do |id|
      cheque_register = ChequeRegister.find(id.to_i)
      cheque_register.update_attribute(:is_active, false)
    end
    render json: {status: :ok}
  end

  private
    def set_cheque_register
      @cheque_register = ChequeRegister.find(params[:id])
    end

    def set_delete_all_cheque_register
      @cheque_register_ids = JSON.parse(params[:ids])
    end

    def cheque_register_params
      params.require(:cheque_register).permit(:id, :payee, :status, :cheque_date, :rate_type, :rate, :notes, :customer_id)
    end

end