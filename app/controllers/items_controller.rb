class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :update]
  before_action :set_delete_all_item, only: [:delete_all]

  def index
    if params[:search_text].present?
      items = Item.search_box(params[:search_text],current_user.id).with_active.get_json_items
    else
      items = Item.search(params,current_user.id).with_active.get_json_items
    end
    render status: 200, json: items.as_json
  end

  def show
    render status: 200, json: @item.get_json_item.as_json    
  end

  def create
    item = Item.new(item_params)
    item.sales_user_id = current_user.id
    if item.save
      render status: 200, json: { item_id: item.id}
    else
      render status: 200, json: { message: item.errors.full_messages.first }
    end
  end 

  def update
    if @item.update_attributes(item_params)
      render status: 200, json: { item_id: @item.id}
    else
      render status: 200, json: { message: @item.errors.full_messages.first }
    end
  end

  def delete_all
    @item_ids.each do |id|
      item = Item.find(id.to_i)
      item.update_attribute(:is_active, false)
    end
    render json: {status: :ok}
  end

  def get_items
    items = Item.sales_items(current_user)
    render status: 200, json: Item.get_json_items_dropdown(items) 
  end

  private
    def set_item
      @item = Item.find(params[:id])
    end

    def set_delete_all_item
      @item_ids = JSON.parse(params[:ids])
    end

    def item_params
      params.require(:item).permit(:id, :name, :category_id, :supplier_id, :unit,
        :tax, :item_in_stock, :max_level, :min_level, :selling_price, :purchase_price,
        :item_description, :purchase_description, :selling_description)
    end
end
