class InvoicesController < ApplicationController
    before_action :set_invoice, only: [:show, :edit_form, :update]
    before_action :set_delete_all_invoice, only: [:delete_all]

    def index
      if params[:search_text].present?
        invoices = Invoice.search_box(params[:search_text],current_user.id).get_json_invoices.get_json_expenses
      else
        invoices = Invoice.search(params,current_user.id,false).with_active.get_json_invoices
      end
      render status: 200, json: invoices.as_json
    end

    def show
      render status: 200, json: @invoice.get_json_invoice_show.as_json   
    end

    def edit_form
      render status: 200, json: @invoice.get_json_invoice_edit.as_json 
    end

    def update
      if @invoice.update_attributes(invoice_params)
        render status: 200, json: { invoice_id: @invoice.id}
      else
        render status: 200, json: { message: @invoice.errors.full_messages.first }
      end
    end

    def delete_all
      @invoice_ids.each do |id|
        ivoice = Invoice.find(id.to_i)
        invoice.update_attribute(:is_active, false)
      end
      render json: {status: :ok}
    end

    private
      def set_invoice
        @invoice = Invoice.find(params[:id])
      end

      def set_delete_all_invoice
        @invoice_ids =JSON.parse(params[:ids])
      end

      def invoice_params
        params.require(:invoice).permit(:id, :customer_user_id, :contact_user_id)
      end
end
