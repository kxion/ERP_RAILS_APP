class KbCategory < ActiveRecord::Base
  #Has Many Relationship
  has_many :knowledge_bases, class_name: "KnowledgeBase", foreign_key: "kb_category_id"

  #Scope For the Active Record
  scope :with_active, -> { where('is_active = ?', true) }
  
  #Creator,Updater to your ActiveRecord objects
  track_who_does_it

  def self.search_box(search_text,current_user_id)
    search = where("kb_categories.sales_user_id = ?",current_user_id)
    if !/\A\d+\z/.match(search_text)
      code = search_text.gsub(/\D/,'')
      if code.present?
        search = search.where(id: code.to_i)
      else
        search = search.where("name LIKE :search OR description LIKE :search 
            ", search: "%#{search_text}%")
      end
    else
      search = search.where("postalcode = ?", search_text)
    end
    return search
  end

  def self.search(params,current_user_id)
    search = where("kb_categories.sales_user_id = ?",current_user_id)
    search = search.where("kb_categories.id = ?",params[:code].gsub(/\D/,'')) if params[:code].present?
    search = search.where('kb_categories.name = ?',params[:name]) if params[:name].present?
    search = search.where('kb_categories.description = ?',params[:description]) if params[:description].present?
    search = search.where('DATE(kb_categories.created_at) = ?', params[:created_at].to_date) if params[:created_at].present?
    search = search.where('kb_categories.created_by_id = ?',params[:created_by_id]) if params[:created_by_id].present?
    return search
  end

  def get_json_kb_category
    as_json(only: [:id, :name, :description])
    .merge({
      code:"KBC#{self.id.to_s.rjust(4, '0')}",
      created_at:self.created_at.strftime('%d %B, %Y'),
      created_by:self.creator.try(:full_name),
      updated_at:self.updated_at.strftime('%d %B, %Y'),
      updated_by:self.updater.try(:full_name),
        knowledge_bases: self.knowledge_bases.with_active.get_json_knowledge_bases
    })
  end 

  def self.get_json_kb_categories
    kb_categories_list =[]
    all.each do |kb_category|
      kb_categories_list << kb_category.get_json_kb_category
    end
    return kb_categories_list
  end

  def self.sales_kb_categories(current_user)
      where("kb_categories.sales_user_id = ? AND kb_categories.is_active = ?",current_user.id,true)
  end

  def self.get_json_kb_categories_dropdown(kb_categories)
    list = []
    kb_categories.each do |kb_category|
      list << as_json(only: [])
      .merge({name:kb_category.name,
          kb_category_id:kb_category.id,
      })
    end
    return list
  end
end