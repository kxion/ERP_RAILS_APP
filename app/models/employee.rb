class Employee < ActiveRecord::Base
  mount_uploader :photo, AvatarUploader

  #Belongs To Relationship
  belongs_to :user
  
  #Has Many Relationship
  has_many :expenses, dependent: :destroy
  has_many :payrolls, dependent: :destroy
  has_many :timeclocks, dependent: :destroy
  has_many :knowledge_bases, class_name: "KnowledgeBase", foreign_key: "author_id"
  has_many :knowledge_bases, class_name: "KnowledgeBase", foreign_key: "approver_id"

  #Scope For the Active Record
  scope :with_active, -> { where('is_active = ?', true) }
  
  #Creator,Updater to your ActiveRecord objects
  track_who_does_it

  def self.search_box(search_text,current_user_id)
    search = where("employees.sales_user_id = ?",current_user_id)
    if !/\A\d+\z/.match(search_text)
      code = search_text.gsub(/\D/,'')
      if code.present?
        search = search.where(id: code.to_i)
      else
        search = search.where("marital_status LIKE :search OR designation LIKE :search
              OR department LIKE :search ", search: "%#{search_text}%")
      end
    else
      search = search.where(id :search_text.to_i)
    end
    return search
  end

  def self.search(params,current_user_id)
    search = where("employees.sales_user_id = ?",current_user_id)
    search = search.where("employees.id = ?",params[:code].gsub(/\D/,'')) if params[:code].present?
    search = search.where('employees.designation = ?',params[:designation]) if params[:designation].present?
    search = search.where('employees.department = ?',params[:department]) if params[:department].present?
    search = search.where('employees.marital_status = ?',params[:marital_status]) if params[:marital_status].present?
    search = search.where('employees.created_by_id = ?',params[:created_by]) if params[:created_by].present?
    search = search.where('DATE(employees.created_at) = ?', params[:created_at].to_date) if params[:created_at].present?
    search = search.joins(:user).where("lower(users.first_name) LIKE ?" ,"%#{params[:first_name].downcase}%") if params[:first_name].present?
    search = search.joins(:user).where("lower(users.last_name) LIKE ?" ,"%#{params[:last_name].downcase}%") if params[:last_name].present?
    return search
  end

  def get_json_employee
    has_photo = self.photo.url.present? ? true : false
    date_of_birth = self.date_of_birth.present? ? self.date_of_birth.strftime('%d %B, %Y') : self.date_of_birth
    date_of_joining = self.date_of_joining.present? ? self.date_of_joining.strftime('%d %B, %Y') : self.date_of_joining
    as_json(only: [:id, :salutation,:gender, :b_group, :nationality, :designation,
      :department, :e_type, :work_shift, :reporting_person,:allow_login, :religion,
      :marital_status, :mobile, :phone_office, :phone_home,:permanent_address_street,
      :permanent_address_city, :permanent_address_state,:permanent_address_postalcode,
      :permanent_address_country,:resident_address_street, :resident_address_city,
      :resident_address_state,:resident_address_postalcode, :resident_address_country])
    .merge({
      code:"EMP#{self.id.to_s.rjust(4, '0')}",
      name: self.user.full_name,
      first_name: self.user.first_name,
      last_name: self.user.last_name,
      middle_name: self.user.middle_name,
      email: self.user.email,
      date_of_joining: date_of_joining,
      date_of_birth: date_of_birth,
      created_at:self.created_at.strftime('%d %B, %Y'),
      created_by:self.creator.try(:full_name),
      updated_at:self.updated_at.strftime('%d %B, %Y'),
      updated_by:self.updater.try(:full_name),
      photo:"https://erp-rails.herokuapp.com#{self.photo.url}",
      timeclocks: self.timeclocks.with_active.get_json_timeclocks,
      expenses: self.expenses.with_active.get_json_expenses,
      payrolls: self.payrolls.with_active.get_json_payrolls,
      has_photo:has_photo,
    })
  end 

  def self.get_json_employees
    employees_list =[]
    all.each do |employee|
      employees_list << employee.get_json_employee
    end
    return employees_list
  end

  def get_json_employee_edit
    as_json(only: [])
    .merge({
      id: self.user.id,
      email: self.user.email,
      first_name: self.user.first_name,
      last_name: self.user.last_name,
      middle_name: self.user.middle_name,
      employee_attributes:{
        id: self.id,
        salutation: self.salutation,
        gender: self.gender, 
        b_group: self.b_group, 
        nationality: self.nationality, 
        designation: self.designation,
        department: self.department, 
        e_type: self.e_type, 
        work_shift: self.work_shift, 
        reporting_person: self.reporting_person,
        allow_login: self.allow_login, 
        religion: self.religion,
        marital_status: self.marital_status, 
        mobile: self.mobile, 
        phone_office: self.phone_office, 
        phone_home: self.phone_home,
        date_of_birth: self.date_of_birth,
        date_of_joining: self.date_of_joining,
        permanent_address_street: self.permanent_address_street,
        permanent_address_city: self.permanent_address_city, 
        permanent_address_state: self.permanent_address_state,
        permanent_address_postalcode: self.permanent_address_postalcode,
        permanent_address_country: self.permanent_address_country,
        resident_address_street: self.resident_address_street, 
        resident_address_city: self.resident_address_city,
        resident_address_state: self.resident_address_state,
        resident_address_postalcode: self.resident_address_postalcode, 
        resident_address_country: self.resident_address_country,
      }
    })
  end 
end