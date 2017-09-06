class KbCategoriesController < ApplicationController
  before_action :set_kb_category, only: [:show, :update]
  before_action :set_delete_all_kb_category, only: [:delete_all]

  def index
    if params[:search_text].present?
      kb_categories = KbCategory.search_box(params[:search_text],current_user.id).with_active.get_json_kb_categories
    else
      kb_categories = KbCategory.search(params,current_user.id).with_active.get_json_kb_categories
    end
    render status: 200, json: kb_categories.as_json
  end

  def show
    render status: 200, json: @kb_category.get_json_kb_category.as_json  
  end

  def create
    kb_category = KbCategory.new(kb_category_params)
    kb_category.sales_user_id = current_user.id
    if kb_category.save
      render status: 200, json: { kb_category_id: kb_category.id}
    else
      render status: 200, json: { message: kb_category.errors.full_messages.first }
    end
  end 

  def update
    if @kb_category.update_attributes(kb_category_params)
      render status: 200, json: { kb_category_id: @kb_category.id}
    else
      render status: 200, json: { message: @kb_category.errors.full_messages.first }
    end
  end

  def delete_all
    @kb_category_ids.each do |id|
      kb_category = KbCategory.find(id.to_i)
      kb_category.update_attribute(:is_active, false)
    end
    render json: {status: :ok}
  end

  def get_kb_categories
    kb_categories = KbCategory.sales_kb_categories(current_user)
    render status: 200, json: KbCategory.get_json_kb_categories_dropdown(kb_categories) 
  end

  private
    def set_kb_category
      @kb_category = KbCategory.find(params[:id])
    end

    def set_delete_all_kb_category
      @kb_category_ids = JSON.parse(params[:ids])
    end

    def kb_category_params
      params.require(:kb_category).permit(:id, :name, :description)
    end
end
