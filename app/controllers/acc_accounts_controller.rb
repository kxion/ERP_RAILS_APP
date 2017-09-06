class AccAccountsController < ApplicationController

  before_action :set_acc_account, only: [:show, :update]
  before_action :set_delete_all_acc_account, only: [:delete_all]

  def index
    if params[:search_text].present?
      acc_accounts = AccAccount.search_box(params[:search_text],current_user.id).with_active.get_json_acc_accounts
    else
      acc_accounts = AccAccount.search(params,current_user.id).with_active.get_json_acc_accounts
    end
    render status: 200, json: acc_accounts.as_json
  end

  def show
    render status: 200, json: @acc_account.get_json_acc_account.as_json   
  end

  def create
    acc_account = AccAccount.new(acc_account_params)
    acc_account.sales_user_id = current_user.id
    if acc_account.save
      render status: 200, json: { acc_account_id: acc_account.id }
    else
      render status: 200, json: { message: acc_account.errors.full_messages.first }
    end
  end 

  def update
    if @acc_account.update_attributes(acc_account_params)
      render status: 200, json: { acc_account_id: @acc_account.id }
    else
      render status: 200, json: { message: @acc_account.errors.full_messages.first }
    end
  end

  def delete_all
    @acc_account_ids.each do |id|
      acc_account = AccAccount.find(id.to_i)
      acc_account.update_attribute(:is_active, false)
    end
    render json: {status: :ok}
  end

  def get_acc_accounts
    acc_accounts = AccAccount.sales_acc_accounts(current_user)
    render status: 200, json: AccAccount.get_json_acc_accounts_dropdown(acc_accounts)
  end

  private
    def set_acc_account
      @acc_account = AccAccount.find(params[:id])
    end

    def set_delete_all_acc_account
      @acc_account_ids = JSON.parse(params[:ids])
    end

    def acc_account_params
      params.require(:acc_account).permit(:id, :acc_code, :name, :acc_type, :description)
    end
end