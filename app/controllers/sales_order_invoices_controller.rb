class SalesOrderInvoicesController < ApplicationController
    before_action :set_invoice, only: [:show, :update, :edit_form]
    before_action :set_delete_all_invoice, only: [:delete_all]

    def index
      if params[:search_text].present?
        invoices = Invoice.search_box(params[:search_text],current_user.id).get_json_invoices
      else
        invoices = Invoice.search(params,current_user.id,true).get_json_invoices
      end
      render status: 200, json: invoices.as_json
    end

    def show
      render status: 200, json: @invoice.get_json_invoice_show.as_json  
    end

    def update
      if @invoice.update_attributes(update_invoice_params)
        render status: 200, json: { invoice_id: @invoice.id}
      else
        render status: 200, json: { message: @invoice.errors.full_messages.first }
      end
    end

    def create
      invoice = Invoice.new(invoice_params)
      invoice.sales_user_id = current_user.id
      if invoice.save
        render status: 200, json: { invoice_id: invoice.id}
      else
        render status: 200, json: { message: invoice.errors.full_messages.first }
      end
    end 

    def create_invoice
      sales_order = SalesOrder.find(params[:id])
      invoice = sales_order.create_invoice
      unless invoice.errors.present?
        render status: 200, json: { invoice_id: invoice.id}
      else
        render status: 200, json: { message: invoice.errors.full_messages.first }
      end
    end 

    def delete_all
      @invoice_ids.each do |id|
        invoice = Invoice.find(id.to_i)
        invoice.update_attribute(:is_active, false)
      end
      render json: {status: :ok}
    end

    def edit_form
      render status: 200, json: @invoice.get_json_invoice_edit.as_json 
    end

    def get_sales_order_invoices
      sales_order_invoices = Invoice.sales_sales_order_invoices(current_user)
      render status: 200, json: Invoice.get_json_sales_order_invoices_dropdown(sales_order_invoices)
    end
  
    private
      def set_invoice
        @invoice = Invoice.find(params[:id])
      end

      def set_delete_all_invoice
        @invoice_ids = JSON.parse(params[:ids])
      end

      def invoice_params
        params.require(:invoice).permit(:id,:customer_user_id,:contact_user_id,:sales_order_id,:name,:subtotal,
          :tax,:grand_total,:account_id,:uid,:buyer_id,:order_shipping_detail_id,
          :payment_status,:paid_at,:refunded_at,:shipped,:shipped_at,:cancelled,
          :cancelled_at,:cancel_reason,:notes,:payment_method,:create_timestamp,
          :update_timestamp,:discount,:marketplace_fee,:processing_fee,:status,
          :profit_share_deductions, :net, :acquisition_cost,
          order_shipping_detail_attributes:[:price,:name,:phone,:city,:state,:country,:postal_code,:address_line_1,
            :address_line_2,:carrier,:tracking_code,:tracking_url,:notes,:available_carriers,
            :buyer_id,:real_price],
          buyer_attributes:[:email,:uid,:name,:phone_number])
      end

      def update_invoice_params
        params.permit(:id,:customer_user_id,:contact_user_id,:sales_order_id,:name,:subtotal,
          :tax,:grand_total,:account_id,:uid,:buyer_id,:order_shipping_detail_id,
          :payment_status,:paid_at,:refunded_at,:shipped,:shipped_at,:cancelled,
          :cancelled_at,:cancel_reason,:notes,:payment_method,:create_timestamp,
          :update_timestamp,:discount,:marketplace_fee,:processing_fee,:status,
          :profit_share_deductions, :net, :acquisition_cost,
          order_shipping_detail_attributes:[:id,:price,:name,:phone,:city,:state,:country,:postal_code,:address_line_1,
            :address_line_2,:carrier,:tracking_code,:tracking_url,:notes,:available_carriers,
            :buyer_id,:real_price],
          buyer_attributes:[:id,:email,:uid,:name,:phone_number])
      end
end