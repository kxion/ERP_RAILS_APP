class Manufacturing < ActiveRecord::Base
  #Belongs To Relationship
  belongs_to :item
  belongs_to :sales_order

  #Has Many Relationship
  has_many :materials
  has_many :qa_check_lists
  has_many :manufacturing_materials
  has_many :manufacturing_histories

  #After Save Call Function
  after_save :create_manufacturing_history

  #Scope For the Active Record
  scope :with_active, -> { where('is_active = ?', true) }
  
  #Creator,Updater to your ActiveRecord objects
  track_who_does_it

  def create_manufacturing_history
    if self.status_changed? and ['Failed','Failed & Restarted'].include? self.status
      manufacturing_history = ManufacturingHistory.new(self.dup.attributes)
      manufacturing_history.manufacturing_id = self.id
      manufacturing_history.save()
    end
  end

  def self.search_box(search_text,current_user_id)
    search = where("manufacturings.sales_user_id = ?",current_user_id)
    if !/\A\d+\z/.match(search_text)
      code = search_text.gsub(/\D/,'')
      if code.present?
        search = search.where(id: code.to_i)
      else
        search = search.where("subject LIKE :search OR status LIKE :search
              OR m_type LIKE :search OR description LIKE :search", search: "%#{search_text}%")
      end
    else
      search = search.where("quantity = ?", search_text)
    end
    return search
  end

  def self.search(params,current_user_id)
    status = JSON.parse(params[:status]) if params[:status].present?
    m_type = JSON.parse(params[:m_type]) if params[:m_type].present?

    search = where("manufacturings.sales_user_id = ?",current_user_id)
    search = search.where("manufacturings.id = ?",params[:code].gsub(/\D/,'')) if params[:code].present?
    search = search.where('manufacturings.subject = ?',params[:subject]) if params[:subject].present?
    search = search.where('manufacturings.status IN (?)',status) if status.present?
    search = search.where('manufacturings.m_type IN (?)',m_type) if m_type.present?
    search = search.where('manufacturings.quantity = ?',params[:quantity]) if params[:quantity].present?
    search = search.where('manufacturings.description = ?',params[:description]) if params[:description].present?
    search = search.where('DATE(manufacturings.start_date) = ?', params[:start_date].to_date) if params[:start_date].present?
    search = search.where('DATE(manufacturings.expected_completion_date) = ?', params[:expected_completion_date].to_date) if params[:expected_completion_date].present?
    search = search.where('DATE(manufacturings.created_at) = ?', params[:created_at].to_date) if params[:created_at].present?
    search = search.where('manufacturings.created_by_id = ?',params[:created_by_id]) if params[:created_by_id].present?
    return search
  end

  def get_json_manufacturing
    sales_order_code = "SO-#{self.sales_order_id.to_s.rjust(4, '0')}" if self.sales_order.present?
    as_json(only: [:id, :subject, :description, :status, :m_type,
      :quantity, :item_id, :sales_order_id, :start_date, :expected_completion_date])
    .merge({
      code:"MFG#{self.id.to_s.rjust(4, '0')}",
      sales_order:sales_order_code,
      item:self.item.try(:name),
      created_at:self.created_at.strftime('%d %B, %Y'),
      created_by:self.creator.try(:full_name),
      updated_at:self.updated_at.strftime('%d %B, %Y'),
      updated_by:self.updater.try(:full_name),
      materials:self.materials.with_active.get_json_materials,
      qa_check_list:self.qa_check_lists,
      manufacturing_histories:self.manufacturing_histories.get_json_manufacturing_histories,
      manufacturing_materials:self.manufacturing_materials.get_json_manufacturing_materials,
    })
  end 

  def self.get_json_manufacturings
    manufacturings_list =[]
    all.each do |manufacturing|
      manufacturings_list << manufacturing.get_json_manufacturing
    end
    return manufacturings_list
  end

  def self.sales_manufacturings(current_user)
    where("manufacturings.sales_user_id = ? AND manufacturings.is_active = ?",current_user.id,true)
  end

  def self.get_json_manufacturings_dropdown(manufacturings)
    list = []
    manufacturings.each do |manufacturing|
      list << as_json(only: [])
      .merge({name:manufacturing.subject,
          manufacturing_id:manufacturing.id,
      })
    end
    return list
  end
end