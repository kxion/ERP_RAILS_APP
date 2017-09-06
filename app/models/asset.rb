class Asset < ActiveRecord::Base

  #Has Many Relationship
  has_many :maintanance_schedules

  #Scope For the Active Record
  scope :with_active, -> { where('is_active = ?', true) }
  
  #Creator,Updater to your ActiveRecord objects
  track_who_does_it

  def self.search_box(search_text,current_user_id)
    search = where("assets.sales_user_id = ?",current_user_id)
    puts search
    if !/\A\d+\z/.match(search_text)
      code = search_text.gsub(/\D/,'')
      if code.present?
        search = search.where(id: code.to_i)
      else
        search = search.where("status LIKE :search
          OR subject LIKE :search OR category LIKE :search OR location LIKE :search", search: "%#{search_text}%")
      end
    else
      search = search.where("id = ?", search_text)
    end
    return search
  end

  def self.search(params,current_user_id)
    search = where("assets.sales_user_id = ?",current_user_id)
    status = params[:status] if params[:status].present?
    category = params[:category] if params[:category].present?
    search = search.where("assets.id = ?",params[:code].gsub(/\D/,'')) if params[:code].present?
    search = search.where('assets.subject = ?',params[:subject]) if params[:subject].present?
    search = search.where('assets.location = ?',params[:location]) if params[:location].present?
    search = search.where('assets.status IN (?)',status) if status.present?
    search = search.where('assets.category IN (?)',category) if category.present?
    search = search.where('DATE(assets.created_at) = ?', params[:created_at].to_date) if params[:created_at].present?
    search = search.where('assets.created_by_id = ?',params[:created_by_id]) if params[:created_by_id].present?
    return search
  end

  def get_json_asset
    as_json(only: [:id,:subject,:status,:category,:location,:description])
    .merge({
      code:"ASS#{self.id.to_s.rjust(4, '0')}",
      created_at:self.created_at.strftime('%d %B, %Y'),
      created_by:self.creator.try(:full_name),
      updated_at:self.updated_at.strftime('%d %B, %Y'),
      updated_by:self.updater.try(:full_name),
      maintanance_schedules:self.maintanance_schedules.with_active.get_json_maintanance_schedules,
    })
  end 

  def self.get_json_assets
    assets_list =[]
    all.each do |asset|
      assets_list << asset.get_json_asset
    end
    return assets_list
  end

  def self.sales_assets(current_user)
    where("assets.sales_user_id = ? AND assets.is_active = ?",current_user.id,true)
  end

  def self.get_json_assets_dropdown(assets)
    list = []
    assets.each do |asset|
      list << as_json(only: [])
      .merge({name:asset.subject,
        asset_id:asset.id,
      })
    end
    return list
  end
end
