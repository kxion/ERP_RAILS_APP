class AssetsController < ApplicationController

  before_action :set_asset, only: [:show, :update]
  before_action :set_delete_all_asset, only: [:delete_all]

  def index
    if params[:search_text].present?
      assets = Asset.search_box(params[:search_text],current_user.id).with_active.get_json_assets
    else
      assets = Asset.search(params,current_user.id).with_active.get_json_assets
    end
    render status: 200, json: assets.as_json
  end

  def show
    render status: 200, json: @asset.get_json_asset.as_json   
  end

  def create
    asset = Asset.new(asset_params)
    asset.sales_user_id = current_user.id
    if asset.save
      render status: 200, json: { asset_id: asset.id }
    else
      render status: 200, json: { message: asset.errors.full_messages.first }
    end
  end 

  def update
    if @asset.update_attributes(asset_params)
      render status: 200, json: { asset_id: @asset.id }
    else
      render status: 200, json: { message: @asset.errors.full_messages.first }
    end
  end

  def delete_all
    @asset_ids.each do |id|
      asset = Asset.find(id.to_i)
      asset.update_attribute(:is_active, false)
    end
    render json: {status: :ok}
  end

  def get_assets
    assets = Asset.sales_assets(current_user)
    render status: 200, json: Asset.get_json_assets_dropdown(assets)
  end

  private
    def set_asset
      @asset = Asset.find(params[:id])
    end

    def set_delete_all_asset
      @asset_ids = JSON.parse(params[:ids])
    end

    def asset_params
      params.require(:asset).permit(:id,:subject,:status,:category,:location,:description)
    end
end