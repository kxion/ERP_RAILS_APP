class ManufacturingsController < ApplicationController
  before_action :set_manufacturing, only: [:show, :update]
  before_action :set_delete_all_manufacturing, only: [:delete_all]

  def index
    if params[:search_text].present?
      manufacturings = Manufacturing.search_box(params[:search_text],current_user.id).with_active.get_json_manufacturings
    else
      manufacturings = Manufacturing.search(params,current_user.id).with_active.get_json_manufacturings
    end
    render status: 200, json: manufacturings.as_json
  end

  def show
    render status: 200, json: @manufacturing.get_json_manufacturing.as_json   
  end

  def create
    manufacturing = Manufacturing.new(manufacturing_params)
    manufacturing.sales_user_id = current_user.id
    if manufacturing.save
      qa_check_list = JSON.parse(params[:manufacturing][:qa_check_list])
      qa_check_list.each do |check|
        passed = check['checked'].present? ? true : false
        QaCheckList.create(name:check['name'],passed:passed,manufacturing_id: manufacturing.id)
      end
      render status: 200, json: { manufacturing_id: manufacturing.id}
    else
      render status: 200, json: { message: manufacturing.errors.full_messages.first }
    end
  end 

  def update
    if @manufacturing.update_attributes(manufacturing_params)
      @manufacturing.qa_check_lists.delete_all
      qa_check_list = JSON.parse(params[:manufacturing][:qa_check_list])
      qa_check_list.each do |check|
        passed = check['passed'].present? ? true : false
        QaCheckList.create(name:check['name'],passed:passed,manufacturing_id: @manufacturing.id)
      end
      render status: 200, json: { manufacturing_id: @manufacturing.id}
    else
      render status: 200, json: { message: @manufacturing.errors.full_messages.first }
    end
  end

  def delete_all
    @manufacturing_ids.each do |id|
      manufacturing = Manufacturing.find(id.to_i)
      manufacturing.update_attribute(:is_active, false)
    end
    render json: {status: :ok}
  end

  def get_manufacturings
    manufacturings = Manufacturing.sales_manufacturings(current_user)
    render status: 200, json: Manufacturing.get_json_manufacturings_dropdown(manufacturings)
  end

  def add_material
    manufacturing_material = ManufacturingMaterial.new(manufacturing_material_params)
    if manufacturing_material.save
      render status: 200, json: { manufacturing_material_id: manufacturing_material.id}
    else
      render status: 200, json: { message: manufacturing_material.errors.full_messages.first }
    end
  end

  private
    def set_manufacturing
      @manufacturing = Manufacturing.find(params[:id])
    end

    def set_delete_all_manufacturing
      @manufacturing_ids = JSON.parse(params[:ids])
    end

    def manufacturing_params
      params.require(:manufacturing).permit(:id, :subject, :description, :status,
       :m_type, :quantity, :item_id, :sales_order_id, :start_date, :expected_completion_date)
    end

    def manufacturing_material_params
      params.require(:manufacturing_material).permit(:id, :manufacturing_id, :material_id, :quantity, :total, :unit_price)
    end
end