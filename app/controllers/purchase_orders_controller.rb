class PurchaseOrdersController < ApplicationController
  before_action :set_purchase_order, only: [:show, :edit_form, :update]
  before_action :set_delete_all_purchase_order, only: [:delete_all]

  def index
    if params[:search_text].present?
      purchase_orders = PurchaseOrder.search_box(params[:search_text],current_user.id).with_active.get_json_purchase_orders
    else
      purchase_orders = PurchaseOrder.search(params,current_user.id).with_active.get_json_purchase_orders
    end
    render status: 200, json: purchase_orders.as_json
  end

  def show
    render status: 200, json: @purchase_order.get_json_purchase_order.as_json  
  end

  def create
    purchase_order = PurchaseOrder.new(purchase_order_params)
    purchase_order.sales_user_id = current_user.id
    if purchase_order.save
      render status: 200, json: { purchase_order_id: purchase_order.id}
    else
      render status: 200, json: { message: purchase_order.errors.full_messages.first }
    end
  end

  def add_item
    item_purchase_order = PurchaseOrderItem.new(item_purchase_order_params)
    if item_purchase_order.save
      render status: 200, json: { item_purchase_order_id: item_purchase_order.id}
    else
      render status: 200, json: { message: item_purchase_order.errors.full_messages.first }
    end
  end

  def edit_form
    render status: 200, json: @purchase_order.get_json_purchase_order_edit.as_json 
  end

  def update
    if @purchase_order.update_attributes(purchase_order_params)
      render status: 200, json: { purchase_order_id: @purchase_order.id}
    else
      render status: 200, json: { message: @purchase_order.errors.full_messages.first }
    end
  end

  def delete_all
    @purchase_order_ids.each do |id|
      purchase_order = PurchaseOrder.find(id.to_i)
      purchase_order.update_attribute(:is_active, false)
    end
    render json: {status: :ok}
  end

  private
    def set_purchase_order
      @purchase_order = PurchaseOrder.find(params[:id])
    end

    def set_delete_all_purchase_order
      @purchase_order_ids = JSON.parse(params[:ids])
    end

    def purchase_order_params
      params.require(:purchase_order).permit(:id,:subject,:total_price,:sub_total,
        :tax,:grand_total,:description,:supplier_user_id)
    end

    def item_purchase_order_params
      params.require(:purchase_order_item).permit(:purchase_order_id,:unit_price,:total,:quantity,:item_id)
    end
end