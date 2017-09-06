class CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :update]
  before_action :set_delete_all_category, only: [:delete_all]

  def index
    if params[:search_text].present?
      categories = Category.search_box(params[:search_text], current_user.id).with_active.get_json_categories
    else
      categories = Category.search(params,current_user.id).with_active.get_json_categories
    end
    render status: 200, json: categories.as_json
  end

  def show
    render status: 200, json: @category.get_json_category.as_json    
  end

  def create
    category = Category.new(category_params)
    category.sales_user_id = current_user.id
    if category.save
      render status: 200, json: { category_id: category.id }
    else
      render status: 200, json: { message: category.errors.full_messages.first }
    end
  end 

  def update
    if @category.update_attributes(category_params)
      render status: 200, json: { category_id: @category.id }
    else
      render status: 200, json: { message: @category.errors.full_messages.first }
    end
  end

  def delete_all
    @category_ids.each do |id|
      category = Category.find(id.to_i)
      category.update_attribute(:is_active, false)
    end
    render json: {status: :ok}
  end

  def get_categories
    categories = Category.sales_categories(current_user)
    render status: 200, json: Category.get_json_categories_dropdown(categories)
  end

  private
    def set_category
      @category = Category.find(params[:id])
    end

    def set_delete_all_category
      @category_ids = JSON.parse(params[:ids])
    end

    def category_params
      params.require(:category).permit(:id,:name, :unit, :tax, :manufacturer, :description)
    end
end
