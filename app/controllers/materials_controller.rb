class MaterialsController < ApplicationController
  before_action :set_material, only: [:show, :update]
  before_action :set_delete_all_material, only: [:delete_all]

  def index
    if params[:search_text].present?
      materials = Material.search_box(params[:search_text],current_user.id).with_active.get_json_materials
    else
      materials = Material.search(params,current_user.id).with_active.get_json_materials
    end
    render status: 200, json: materials.as_json
  end

  def show
    render status: 200, json: @material.get_json_material.as_json  
  end

  def create
    material = Material.new(material_params)
    material.sales_user_id = current_user.id
    if material.save
      render status: 200, json: { material_id: material.id}
    else
      render status: 200, json: { message: material.errors.full_messages.first }
    end
  end 

  def update
    if @material.update_attributes(material_params)
      render status: 200, json: { material_id: @material.id}
    else
      render status: 200, json: { message: @material.errors.full_messages.first }
    end
  end

  def delete_all
    @material_ids.each do |id|
      material = Material.find(id.to_i)
      material.update_attribute(:is_active, false)
    end
    render json: {status: :ok}
  end

  def get_materials
    materials = Material.sales_materials(current_user)
    render status: 200, json: Material.get_json_materials_dropdown(materials)
  end

  private
    def set_material
      @material = Material.find(params[:id])
    end

    def set_delete_all_material
      @material_ids = JSON.parse(params[:ids])
    end

    def material_params
      params.require(:material).permit(:id, :manufacturing_id, :name, :description, :unit, :quantity, :price)
    end
end