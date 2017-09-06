class Timeclock < ActiveRecord::Base
  #Belongs To Relationship
  belongs_to :employees

  #Scope For the Active Record
  scope :with_active, -> { where('is_active = ?', true) }
  
  #Creator,Updater to your ActiveRecord objects
  track_who_does_it

  def self.search_box(search_text,current_user_id)
    search = where("timeclocks.sales_user_id = ?",current_user_id)
    if !/\A\d+\z/.match(search_text)
      code = search_text.gsub(/\D/,'')
      if code.present?
        search = search.where(id: code.to_i)
      else
        search = search.where("subject LIKE :search", search: "%#{search_text}%")
      end
    else
      search = search.where("id :search", search: "%#{search_text}%")
    end
    return search
  end

  def self.search(params,current_user_id)
    search = where("timeclocks.sales_user_id = ?",current_user_id)
    search = search.where("timeclocks.id = ?",params[:code].gsub(/\D/,'')) if params[:code].present?
    search = search.where('timeclocks.subject = ?',params[:subject]) if params[:subject].present?
    search = search.where('timeclocks.employee_id = ?',params[:employee_id]) if params[:employee_id].present?
    search = search.where('DATE(timeclocks.created_at) = ?', params[:created_at].to_date) if params[:created_at].present?      
    search = search.where('timeclocks.created_by_id = ?',params[:created_by_id]) if params[:created_by_id].present?
    return search
  end

  def get_json_timeclock
    as_json(only: [:id,:subject, :employee_id, :in_time,:out_time])
    .merge({
      code:"Timeclock#{self.id.to_s.rjust(4, '0')}",
      employee: Employee.find_by_id(self.employee_id).try(:user).try(:full_name),
      str_in_time: self.in_time.strftime('%I:%M %p'),
      str_out_time: self.out_time.strftime('%I:%M %p'),
      created_at:self.created_at.strftime('%d %B, %Y'),
      created_by:self.creator.try(:full_name),
      updated_at:self.updated_at.strftime('%d %B, %Y'),
      updated_by:self.updater.try(:full_name),
    })
  end 

  def self.get_json_timeclocks
    timeclocks_list =[]
    all.each do |timeclock|
      timeclocks_list << timeclock.get_json_timeclock
    end
    return timeclocks_list
  end
end