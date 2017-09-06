class EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :edit_form]
  before_action :set_delete_all_employee, only: [:delete_all]

  def index
    if params[:search_text].present?
      employees = Employee.search_box(params[:search_text],current_user.id).with_active.get_json_employees
    else
      employees = Employee.search(params,current_user.id).with_active.get_json_employees
    end
    render status: 200, json: employees.as_json
  end

  def show
    render status: 200, json: @employee.get_json_employee.as_json    
  end

  def create
    user = User.new(employee_params)
    user.employee.sales_user_id = current_user.id
    if user.save
      render status: 200, json: { employee_id: user.employee.id}
    else
      render status: 200, json: { message: user.errors.full_messages.first }
    end
  end 

  def edit_form
    render status: 200, json: @employee.get_json_employee_edit.as_json  
  end

  def update
    user = User.find(params[:id])
    if user.update_attributes(update_employee_params)
      render status: 200, json: { employee_id: user.employee.id}
    else
      render status: 200, json: { message: user.errors.full_messages.first }
    end
  end

  def delete_all
    @employee_ids.each do |id|
      employee = Employee.find(id.to_i)
      employee.update_attribute(:is_active, false)
    end
    render json: {status: :ok}
  end

  def get_employees
    employees = User.sales_employees(current_user)
    render status: 200, json: User.get_json_employees_dropdown(employees) 
  end

  def upload_photo
    uploader = AvatarUploader.new
    File.read(params[:file].tempfile.path) do |file|
      something = uploader.store!(file)
    end
  end

  private
    def set_employee
      @employee = Employee.find(params[:id])
    end

    def set_delete_all_employee
      @employee_ids = JSON.parse(params[:ids])
    end

    def employee_params
      params = ActionController::Parameters.new(JSON.parse(request.POST[:employee]))
      params[:employee][:employee_attributes][:photo] = request.POST['file']
      params.require(:employee).permit(:id,:email,:role,:password,:password_confirmation,:first_name,:last_name,:middle_name,
        employee_attributes:[:id, :salutation, :date_of_birth, :gender, :b_group, :nationality, :designation,
      :department, :e_type, :work_shift, :reporting_person, :date_of_joining,
        :allow_login, :religion, :marital_status, :mobile, :phone_office, :phone_home,
        :permanent_address_street, :permanent_address_city, :permanent_address_state,
        :permanent_address_postalcode, :permanent_address_country,
        :resident_address_street, :resident_address_city, :resident_address_state,
          :resident_address_postalcode, :resident_address_country,:photo])
    end

    def update_employee_params
      params = ActionController::Parameters.new(JSON.parse(request.POST[:employee]))
      params[:employee_attributes][:photo] = request.POST['file']
      params.permit(:id,:email,:first_name,:last_name,:middle_name,:password_confirmation,
        employee_attributes:[:id, :salutation, :date_of_birth, :gender, :b_group, :nationality, :designation,
      :department, :e_type, :work_shift, :reporting_person, :date_of_joining,
        :allow_login, :religion, :marital_status, :mobile, :phone_office, :phone_home,
        :permanent_address_street, :permanent_address_city, :permanent_address_state,
        :permanent_address_postalcode, :permanent_address_country,
        :resident_address_street, :resident_address_city, :resident_address_state,
          :resident_address_postalcode, :resident_address_country,:photo])
    end
end
