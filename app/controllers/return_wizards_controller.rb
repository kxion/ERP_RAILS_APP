class ReturnWizardsController < ApplicationController

  before_action :set_return_wizard, only: [:show, :update]
  before_action :set_delete_all_return_wizard, only: [:delete_all]

  def index
    if params[:search_text].present?
      return_wizards = ReturnWizard.search_box(params[:search_text],current_user.id).with_active.get_json_return_wizards
    else
      return_wizards = ReturnWizard.search(params,current_user.id).with_active.get_json_return_wizards
    end
    render status: 200, json: return_wizards.as_json
  end

  def show
    render status: 200, json: @return_wizard.get_json_return_wizard.as_json   
  end

  def create
    return_wizard = ReturnWizard.new(return_wizard_params)
    return_wizard.sales_user_id = current_user.id
    if return_wizard.save
      render status: 200, json: { return_wizard_id: return_wizard.id }
    else
      render status: 200, json: { message: return_wizard.errors.full_messages.first }
    end
  end 

  def update
    if @return_wizard.update_attributes(return_wizard_params)
      render status: 200, json: { return_wizard_id: @return_wizard.id }
    else
      render status: 200, json: { message: @return_wizard.errors.full_messages.first }
    end
  end

  def delete_all
    @return_wizard_ids.each do |id|
      return_wizard = ReturnWizard.find(id.to_i)
      return_wizard.update_attribute(:is_active, false)
    end
    render json: {status: :ok}
  end

  def return_wizards
    return_wizards = ReturnWizard.sales_return_wizards(current_user)
    render status: 200, json: ReturnWizard.get_json_return_wizards_dropdown(return_wizards)
  end

  private
    def set_return_wizard
      @return_wizard = ReturnWizard.find(params[:id])
    end

    def set_delete_all_return_wizard
      @return_wizard_ids = JSON.parse(params[:ids])
    end

    def return_wizard_params
      params.require(:return_wizard).permit(:id, :subject, :invoice_id, :customer_id,
       		:original_amount, :shipping_charges, :amount_to_be_refunded, :refund_type,
       		:payment_type, :date_paid, :status, :reason_for_return, :return_description)
    end

end
