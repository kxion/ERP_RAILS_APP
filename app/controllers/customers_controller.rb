class CustomersController < ApplicationController
  before_action :set_customer, only: [:show, :edit_form]
  before_action :set_delete_all_customer, only: [:delete_all]

  def index
    if params[:search_text].present?
      customers = Customer.search_box(params[:search_text],current_user.id).with_active.get_json_customers
    else
      customers = Customer.search(params,current_user.id).with_active.get_json_customers
    end
    puts customers
    render status: 200, json: customers.as_json
  end

  def show
    render status: 200, json: @customer.get_json_customer_show.as_json    
  end

  def edit_form
    render status: 200, json: @customer.get_json_customer_edit.as_json
  end

  def create
    user = User.new(customer_params)
    user.customer.sales_user_id = current_user.id
    if user.save
      render status: 200, json: { customer_id: user.customer.id}
    else
      render status: 200, json: { message: user.errors.full_messages.first }
    end
  end 

  def update
    user = User.find(params[:id])
    if user.update_attributes(update_customer_params)
      render status: 200, json: { customer_id: user.customer.id}
    else
      render status: 200, json: { message: user.errors.full_messages.first }
    end
  end

  def get_customers
    users = User.sales_customers(current_user)
    render status: 200, json: User.get_json_customers_dropdown(users) 
  end

  def delete_all
    @customer_id.each do |id|
      customer = Customer.find(id.to_i)
      customer.update_attribute(:is_active, false)
    end
    render json: {status: :ok}
  end

  private
    def set_customer
      @customer = Customer.find(params[:id])
    end

    def set_delete_all_customer
      @customer_id = JSON.parse(params[:ids])
    end

    def update_customer_params
      params.permit(:id,:password, :role, :first_name, :last_name, :email, customer_attributes:[:id, :customer_since, :user_id, :phone, :c_type, :street, :city, :state, :country, :postal_code, :decription, :created_at,:discount_percent, :credit_limit, :tax_reference, :payment_terms, :customer_currency,:created_at, :created_by_id, :updated_at, :updated_by_id])
    end

    def customer_params
      params.require(:customer).permit(:id, :password, :role, :first_name, :last_name, :email, customer_attributes:[:id, :customer_since, :user_id, :phone, :c_type, :street, :city, :state, :country, :postal_code, :decription, :created_at,:discount_percent, :credit_limit, :tax_reference, :payment_terms, :customer_currency,:created_at, :created_by_id, :updated_at, :updated_by_id])
    end
end