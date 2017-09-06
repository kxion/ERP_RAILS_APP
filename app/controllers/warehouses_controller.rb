class WarehousesController < ApplicationController
  before_action :set_warehouse, only: [:show, :update]
  before_action :set_delete_all_warehouse, only: [:delete_all]

  def index
    if params[:search_text].present?
      warehouses = Warehouse.search_box(params[:search_text],current_user.id).with_active.get_json_warehouses
    else
      warehouses = Warehouse.search(params,current_user.id).with_active.get_json_warehouses
    end
    render status: 200, json: warehouses.as_json
  end

  def show
    render status: 200, json: @warehouse.get_json_warehouse.as_json  
  end

  def create
    warehouse = Warehouse.new(warehouse_params)
    warehouse.sales_user_id = current_user.id
    if warehouse.save
      render status: 200, json: { warehouse_id: warehouse.id}
    else
      render status: 200, json: { message: warehouse.errors.full_messages.first }
    end
  end 

  def update
    if @warehouse.update_attributes(warehouse_params)
      render status: 200, json: { warehouse_id: @warehouse.id}
    else
      render status: 200, json: { message: @warehouse.errors.full_messages.first }
    end
  end

  def delete_all
     @warehouse_ids.each do |id|
      warehouse = Warehouse.find(id.to_i)
      warehouse.update_attribute(:is_active, false)
    end
    render json: {status: :ok}
  end

  def get_warehouses
    warehouses = Warehouse.sales_warehouses(current_user)
    render status: 200, json: Warehouse.get_json_warehouses_dropdown(warehouses)
  end

  private
    def set_warehouse
      @warehouse = Warehouse.find(params[:id])
    end

    def set_delete_all_warehouse
      @warehouse_ids = JSON.parse(params[:ids])
    end

    def warehouse_params
      params.require(:warehouse).permit(:id, :subject, :city, :province, :country, :description, :street, :postalcode)
    end
end