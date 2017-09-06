class WarehouseLocationsController < ApplicationController
  before_action :set_warehouse_location, only: [:show, :update]
  before_action :set_delete_all_warehouse_location, only: [:delete_all]

  def index
    if params[:search_text].present?
      warehouse_locations = WarehouseLocation.search_box(params[:search_text],current_user.id).with_active.get_json_warehouse_locations
    else
      warehouse_locations = WarehouseLocation.search(params,current_user.id).with_active.get_json_warehouse_locations
    end
    render status: 200, json: warehouse_locations.as_json
  end

  def show
    render status: 200, json: @warehouse_location.get_json_warehouse_location.as_json 
  end

  def create
    warehouse_location = WarehouseLocation.new(warehouse_location_params)
    warehouse_location.sales_user_id = current_user.id
    if warehouse_location.save
      render status: 200, json: { warehouse_location_id: warehouse_location.id}
    else
      render status: 200, json: { message: warehouse_location.errors.full_messages.first }
    end
  end 

  def add_item
    warehouse_location_item = WarehouseLocationItem.new(warehouse_location_item_params)
    if warehouse_location_item.save
      render status: 200, json: { warehouse_location_item_id: warehouse_location_item.id}
    else
      render status: 200, json: { message: warehouse_location_item.errors.full_messages.first }
    end
  end

  def remove_item
    @warehouse_location_item = WarehouseLocationItem.find_by(id: params[:location_item_id])
    if @warehouse_location_item.delete
      render status: 200, json: { message: 'Item deleted'}
    else
      render status: 200, json: { message: @warehouse_location_item.errors.full_messages.first }
    end
  end

  def update
    if @warehouse_location.update_attributes(warehouse_location_params)
      render status: 200, json: { warehouse_location_id: @warehouse_location.id}
    else
      render status: 200, json: { message: @warehouse_location.errors.full_messages.first }
    end
  end

  def delete_all
    @warehouse_location_ids.each do |id|
      warehouse_location = WarehouseLocation.find(id.to_i)
      warehouse_location.update_attribute(:is_active, false)
    end
    render json: {status: :ok}
  end

  def get_warehouse_locations
    warehouse_locations = WarehouseLocation.sales_warehouse_locations(current_user)
    render status: 200, json: WarehouseLocation.get_json_warehouse_locations_dropdown(warehouse_locations)
  end

  private
    def set_warehouse_location
      @warehouse_location = WarehouseLocation.find(params[:id])
    end

    def set_delete_all_warehouse_location
      @warehouse_location_ids = JSON.parse(params[:ids])
    end

    def warehouse_location_params
      params.require(:warehouse_location).permit(:id, :asset, :sku, :subject, :row_no, :warehouse_id, :status, :description, :rack_from, :rack_to)
    end

    def warehouse_location_item_params
      params.require(:warehouse_location_item).permit(:warehouse_location_id, :item_id, :item_in_stock)
    end
end