class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :update, :disconnect_account, :connect_account]

  def get_accounts
    render status: 200, json: { accounts: current_user.accounts }
  end

  def get_marketplaces
    render status: 200, json: { marketplace: Marketplace.all }
  end

  def create
    account = Account.new(account_params)
    if account.save
      render status: 200, json: { account_id: account.id }
    else
      render status: 200, json: { message: account.errors.full_messages.first }
    end
  end 

  def show
    render status: 200, json: @account.get_json_account    
  end

  def update
    if @account.update_attributes(update_account_params)
      if params[:sale_events_attributes].present?
        params[:sale_events_attributes].each do |sale_events|
          if sale_events[:id].blank? and sale_events[:is_delete] == false
            @account.sale_events.create(sale_events.permit(:category_id,:start_date,:end_date,:discount_percent))
          elsif sale_events[:id].present? and sale_events[:is_delete] == false
            @account.sale_events.find(sale_events[:id]).update_attributes(sale_events.permit(:category_id,:start_date,:end_date,:discount_percent))
          elsif sale_events[:id].present? and sale_events[:is_delete]
            @account.sale_events.find(sale_events[:id]).destroy
          end
        end
      end
      render status: 200, json: { account_id: @account.id }
    else
      render status: 200, json: { message: @account.errors.full_messages.first }
    end
  end

  def disconnect_account
    if @account.update_attributes(state: nil, is_connected: false)
      render status: 200, json: { account_id: @account.id }
    else
      render status: 200, json: { message: @account.errors.full_messages.first }
    end
  end

  def connect_account
    if @account.update_attributes(state: connect_state, is_connected: true)
      render status: 200, json: { account_id: @account.id }
    else
      render status: 200, json: { message: @account.errors.full_messages.first }
    end
  end

  private
    def set_contact
      @account = current_user.accounts.find(params[:id])
    end

    def update_account_params
        params.require(:account).permit(:auto_renew, relisting_pricing:[:unit, :operator, :value])
    end

    def connect_state
      params.permit(:merchant_id, :auth_token)
    end

    def account_params
      params = ActionController::Parameters.new(JSON.parse(request.POST[:marketplace]))
      params[:user_id] = current_user.id
      params[:title] = params[:name]
      params[:marketplace_id] = params[:id]
      params.permit(:user_id, :title ,:marketplace_id)
    end
end