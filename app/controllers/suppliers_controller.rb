class SuppliersController < ApplicationController
  before_action :set_supplier, only: [:show, :edit_form]
  before_action :set_delete_all_supplier, only: [:delete_all]

  def index
    if params[:search_text].present?
      suppliers = Supplier.search_box(params[:search_text],current_user.id).with_active.get_json_suppliers
    else
      suppliers = Supplier.search(params,current_user.id).with_active.get_json_suppliers
    end
    render status: 200, json: suppliers.as_json
  end

  def show
    render status: 200, json: @supplier.get_json_supplier.as_json  
  end

  def create
    user = User.new(supplier_params)
    user.supplier.sales_user_id = current_user.id
    if user.save
      render status: 200, json: { supplier_id: user.supplier.id}
    else
      render status: 200, json: { message: user.errors.full_messages.first }
    end
  end 

  def edit_form
    render status: 200, json: @supplier.get_json_supplier_edit.as_json  
  end

  def update
    user = User.find(params[:id])
    if user.update_attributes(update_supplier_params)
      render status: 200, json: { supplier_id: user.supplier.id}
    else
      render status: 200, json: { message: user.errors.full_messages.first }
    end
  end

  def delete_all
    @supplier_ids.each do |id|
      supplier = Supplier.find(id.to_i)
      supplier.update_attribute(:is_active, false)
    end
    render status: 200, json: {status: :ok}
  end

  def get_suppliers
    suppliers = Supplier.sales_suppliers(current_user)
    render status: 200, json: Supplier.get_json_suppliers_dropdown(suppliers)
  end

  private
    def set_supplier
      @supplier = Supplier.find(params[:id])
    end

    def set_delete_all_supplier
      @supplier_ids = JSON.parse(params[:ids])
    end

    def supplier_params
      params.require(:supplier).permit(:id,:email,:role,:password,:first_name,
        supplier_attributes:[:phone, :country, :supplier_currency,
        :street, :city, :state, :postal_code, :supplier_since])
    end

    def update_supplier_params
      params.permit(:id,:email,:role,:password,:first_name,
        supplier_attributes:[:id,:phone, :country, :supplier_currency,
        :street, :city, :state, :postal_code, :supplier_since])
    end
end