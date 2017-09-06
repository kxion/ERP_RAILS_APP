class LedgerEntriesController < ApplicationController

  before_action :set_ledger_entry, only: [:show, :update]
  before_action :set_delete_all_ledger_entry, only: [:delete_all]

  def index
    if params[:search_text].present?
      ledger_entries = LedgerEntry.search_box(params[:search_text],current_user.id).with_active.get_json_ledger_entries
    else
      ledger_entries = LedgerEntry.search(params,current_user.id).with_active.get_json_ledger_entries
    end
    render status: 200, json: ledger_entries.as_json
  end

  def show
    render status: 200, json: @ledger_entry.get_json_ledger_entry.as_json   
  end

  def create
    ledger_entry = LedgerEntry.new(ledger_entry_params)
    ledger_entry.sales_user_id = current_user.id
    if ledger_entry.save
      render status: 200, json: { ledger_entry_id: ledger_entry.id }
    else
      render status: 200, json: { message: ledger_entry.errors.full_messages.first }
    end
  end 

  def update
    if @ledger_entry.update_attributes(ledger_entry_params)
      render status: 200, json: { ledger_entry_id: @ledger_entry.id }
    else
      render status: 200, json: { message: @ledger_entry.errors.full_messages.first }
    end
  end

  def delete_all
    @ledger_entry_ids.each do |id|
      ledger_entry = LedgerEntry.find(id.to_i)
      ledger_entry.update_attribute(:is_active, false)
    end
    render json: {status: :ok}
  end

  def ledger_entries
    ledger_entries = LedgerEntry.sales_ledger_entries(current_user)
    render status: 200, json: LedgerEntry.get_json_ledger_entries_dropdown(ledger_entries)
  end

  private
    def set_ledger_entry
      @ledger_entry = LedgerEntry.find(params[:id])
    end

    def set_delete_all_ledger_entry
      @ledger_entry_ids = JSON.parse(params[:ids])
    end

    def ledger_entry_params
      params.require(:ledger_entry).permit(:id, :subject, :customer_id, :acc_account_id, :invoice_id, :amount)
    end
end


