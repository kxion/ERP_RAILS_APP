class KnowledgeBase < ActiveRecord::Base
  #Belongs To Relationship
  belongs_to :kb_category
  belongs_to :author, class_name: "Employee", foreign_key: "author_id"
  belongs_to :approver, class_name: "Employee", foreign_key: "approver_id"

  #Scope For the Active Record
  scope :with_active, -> { where('is_active = ?', true) }
  
  #Creator,Updater to your ActiveRecord objects
  track_who_does_it

  def self.search_box(search_text,current_user_id)
    search = where("knowledge_bases.sales_user_id = ?",current_user_id)
    if !/\A\d+\z/.match(search_text)
      code = search_text.gsub(/\D/,'')
      if code.present?
        search = search.where(id: code.to_i)
      else
        search = search.where("status LIKE :search
          OR body LIKE :search OR resolution LIKE :search OR title LIKE :search", search: "%#{search_text}%")
      end
    else
      search = search.where("revision = ?", search_text)
    end
    return search
  end

  def self.search(params,current_user_id)
    search = where("knowledge_bases.sales_user_id = ?",current_user_id)
    # status = JSON.parse(params[:status]) if params[:status].present?
    status = params[:status] if params[:status].present?
    search = search.where("knowledge_bases.id = ?",params[:code].gsub(/\D/,'')) if params[:code].present?
    search = search.where('knowledge_bases.title = ?',params[:title]) if params[:title].present?
    search = search.where('knowledge_bases.revision = ?',params[:revision]) if params[:revision].present?
    search = search.where('knowledge_bases.kb_category_id = ?',params[:kb_category_id]) if params[:kb_category_id].present?
    search = search.where('knowledge_bases.status IN (?)',status) if status.present?
    search = search.where('knowledge_bases.author_id = ?',params[:author_id]) if params[:author_id].present?
    search = search.where('knowledge_bases.approver_id = ?',params[:approver_id]) if params[:approver_id].present?
    search = search.where('DATE(knowledge_bases.created_at) = ?', params[:created_at].to_date) if params[:created_at].present?
    search = search.where('knowledge_bases.created_by_id = ?',params[:created_by_id]) if params[:created_by_id].present?
    return search
  end

  def get_json_knowledge_base
    as_json(only: [:id, :title, :kb_category_id, :status, :revision,
      :body, :resolution, :author_id, :approver_id])
    .merge({
      code:"WHL#{self.id.to_s.rjust(4, '0')}",
      kb_category: self.kb_category.try(:name),
      author: self.author.try(:user).try(:full_name),
      approver: self.approver.try(:user).try(:full_name),
      created_at:self.created_at.strftime('%d %B, %Y'),
      created_by:self.creator.try(:full_name),
      updated_at:self.updated_at.strftime('%d %B, %Y'),
      updated_by:self.updater.try(:full_name),
    })
  end 

  def self.get_json_knowledge_bases
    knowledge_bases_list =[]
    all.each do |knowledge_base|
      knowledge_bases_list << knowledge_base.get_json_knowledge_base
    end
    return knowledge_bases_list
  end

  def self.sales_knowledge_bases(current_user)
    where("knowledge_bases.sales_user_id = ? AND knowledge_bases.is_active = ?",current_user.id,true)
  end

  def self.get_json_knowledge_bases_dropdown(knowledge_bases)
    list = []
    knowledge_bases.each do |knowledge_base|
      list << as_json(only: [])
      .merge({name:knowledge_base.subject,
        knowledge_base_id:knowledge_base.id,
      })
    end
    return list
  end
end