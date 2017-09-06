class Payroll < ActiveRecord::Base
  #Belongs To Relationship
  belongs_to :employees

  #Scope For the Active Record
  scope :with_active, -> { where('is_active = ?', true) }
  
  #Creator,Updater to your ActiveRecord objects
  track_who_does_it

  def self.search_box(search_text,current_user_id)
    search = where("payrolls.sales_user_id = ?",current_user_id)
    if !/\A\d+\z/.match(search_text)
      code = search_text.gsub(/\D/,'')
      if code.present?
        search = search.where(id: code.to_i)
      else
        search = search.where("subject LIKE :search", search: "%#{search_text}%")
      end
    else
      search = search.where("employee_id :search OR id :search", search: "%#{search_text}%")
    end
    return search
  end

  def self.search(params,current_user_id)
    search = where("payrolls.sales_user_id = ?",current_user_id)
    search = search.where("payrolls.id = ?",params[:code].gsub(/\D/,'')) if params[:code].present?
    search = search.where('payrolls.subject = ?',params[:subject]) if params[:subject].present?
    search = search.where('payrolls.employee_id = ?',params[:employee_id]) if params[:employee_id].present?
    search = search.where('DATE(payrolls.created_at) = ?', params[:created_at].to_date) if params[:created_at].present?      
    search = search.where('payrolls.created_by_id = ?',params[:created_by_id]) if params[:created_by_id].present?
    return search
  end

  def self.report_search(params,current_user_id)
    search = where("payrolls.sales_user_id = ?",current_user_id)
    search = search.where('payrolls.employee_id = ?',params[:employee_id]) if params[:employee_id].present?
    search = search.where(:created_at => params[:from_date]..params[:to_date]) if params[:from_date].present? and params[:to_date].present?
    return search
  end

  def get_json_payroll
    as_json(only: [:id,:subject, :employee_id, :base_pay,
      :allowances, :deductions, :expenses, :tax, :total])
    .merge({
      code:"PAYROLL#{self.id.to_s.rjust(4, '0')}",
      employee: Employee.find_by_id(self.employee_id).try(:user).try(:full_name),
      created_at:self.created_at.strftime('%d %B, %Y'),
      created_by:self.creator.try(:full_name),
      updated_at:self.updated_at.strftime('%d %B, %Y'),
      updated_by:self.updater.try(:full_name),
    })
  end 

  def self.get_json_payrolls
    payrolls_list =[]
    all.each do |payroll|
      payrolls_list << payroll.get_json_payroll
    end
    return payrolls_list
  end
end