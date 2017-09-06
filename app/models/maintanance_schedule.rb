class MaintananceSchedule < ActiveRecord::Base

  #Belongs To Relationship
  belongs_to :asset

  #Scope For the Active Record
  scope :with_active, -> { where('is_active = ?', true) }
  
  #Creator,Updater to your ActiveRecord objects
  track_who_does_it

  def self.search_box(search_text,current_user_id)
    search = where("maintanance_schedules.sales_user_id = ?",current_user_id)
    if !/\A\d+\z/.match(search_text)
      code = search_text.gsub(/\D/,'')
      if code.present?
        search = search.where(id: code.to_i)
      else
        search = search.where("status LIKE :search
          OR subject LIKE :search", search: "%#{search_text}%")
      end
    else
      search = search.where("id = ?", search_text)
    end
    return search
  end

  def self.search(params,current_user_id)
    search = where("maintanance_schedules.sales_user_id = ?",current_user_id)
    status = params[:status] if params[:status].present?
    search = search.where("maintanance_schedules.id = ?",params[:code].gsub(/\D/,'')) if params[:code].present?
    search = search.where('maintanance_schedules.subject = ?',params[:subject]) if params[:subject].present?
    search = search.where('maintanance_schedules.asset_id = ?',params[:asset_id]) if params[:asset_id].present?
    search = search.where('maintanance_schedules.status IN (?)',status) if status.present?
    search = search.where('DATE(maintanance_schedules.created_at) = ?', params[:created_at].to_date) if params[:created_at].present?
    search = search.where('DATE(maintanance_schedules.schedule_date) = ?', params[:schedule_date].to_date) if params[:schedule_date].present?
    search = search.where('maintanance_schedules.created_by_id = ?',params[:created_by_id]) if params[:created_by_id].present?
    return search
  end

  def get_json_maintanance_schedule
  	schedule_date = self.schedule_date.present? ? self.schedule_date.strftime('%d %B, %Y') : self.schedule_date
    as_json(only: [:id,:subject,:schedule_date,:asset_id,:status,:description])
    .merge({
      code:"MSH#{self.id.to_s.rjust(4, '0')}",
      asset: self.asset.try(:subject),
      schedule_date: schedule_date,
      created_at:self.created_at.strftime('%d %B, %Y'),
      created_by:self.creator.try(:full_name),
      updated_at:self.updated_at.strftime('%d %B, %Y'),
      updated_by:self.updater.try(:full_name),
    })
  end 

  def self.get_json_maintanance_schedules
    maintanance_schedules_list =[]
    all.each do |maintanance_schedule|
      maintanance_schedules_list << maintanance_schedule.get_json_maintanance_schedule
    end
    return maintanance_schedules_list
  end

  def self.sales_maintanance_schedules(current_user)
    where("maintanance_schedules.sales_user_id = ? AND maintanance_schedules.is_active = ?",current_user.id,true)
  end

  def self.get_json_maintanance_schedules_dropdown(maintanance_schedules)
    list = []
    maintanance_schedules.each do |maintanance_schedule|
      list << as_json(only: [])
      .merge({name:maintanance_schedule.subject,
        maintanance_schedule_id:maintanance_schedule.id,
      })
    end
    return list
  end
end