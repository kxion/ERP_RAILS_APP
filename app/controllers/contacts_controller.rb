class ContactsController < ApplicationController
  before_action :set_contact, only: [:show, :edit_form]
  before_action :set_delete_all_contact, only: [:delete_all]

  def index
    if params[:search_text].present?
      contacts = Contact.search_box(params[:search_text],current_user.id).with_active.get_json_contacts
    else
      contacts = Contact.search(params,current_user.id).with_active.get_json_contacts
    end
    render status: 200, json: contacts.as_json
  end

  def show
    render status: 200, json: @contact.get_json_contact_show.as_json    
  end

  def edit_form
    render status: 200, json: @contact.get_json_contact_edit.as_json
  end

  def create
    user = User.new(contact_params)
    user.contact.sales_user_id = current_user.id
    if user.save
      render status: 200, json: { contact_id: user.contact.id }
    else
      render status: 200, json: { message: user.errors.full_messages.first }
    end
  end   

  def update
    user = User.find(params[:id])
    if user.update_attributes(update_contact_params)
      render status: 200, json: { contact_id: user.contact.id }
    else
      render status: 200, json: { message: user.errors.full_messages.first }
    end
  end

  def get_contacts
    users = User.sales_contacts(current_user)   
    render status: 200, json: User.get_json_contacts_dropdown(users)  
  end

  def delete_all
    @contact_ids.each do |id|
      contact = Contact.find(id.to_i)
      contact.update_attribute(:is_active, false)
    end
    render json: {status: :ok}
  end

  private
    def set_contact
      @contact = Contact.find(params[:id])
    end

    def set_delete_all_contact
      @contact_ids = JSON.parse(params[:ids])
    end

    def update_contact_params
      params.permit(:id, :email, :role, :password, :first_name, :middle_name, :last_name, contact_attributes:[:id, :user_id, :customer_id, :salutation, :phone_mobile, :phone_work, :designation, :department, :primary_street, :primary_city, :primary_state, :primary_country, :primary_postal_code, :alternative_street, :alternative_city, :alternative_state, :alternative_country, :alternative_postal_code, :decription, :company, :created_at, :created_by_id, :updated_at, :updated_by_id])
    end

    def contact_params
      params.require(:contact).permit(:id, :email, :role, :password, :first_name, :middle_name, :last_name, contact_attributes:[:id, :user_id, :customer_id, :salutation, :phone_mobile, :phone_work, :designation, :department, :primary_street, :primary_city, :primary_state, :primary_country, :primary_postal_code, :alternative_street, :alternative_city, :alternative_state, :alternative_country, :alternative_postal_code, :decription, :company, :created_at, :created_by_id, :updated_at, :updated_by_id])
    end
end
