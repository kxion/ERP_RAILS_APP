class Category < ActiveRecord::Base
  #Has Many Relationship
  has_many :sale_events
  has_many :items, dependent: :destroy

  #Validations
  validates :name, :unit, :tax, :manufacturer, :description, presence: true
    
  #Scope For the Active Record
  scope :with_active, -> { where('is_active = ?', true) }

  #Creator,Updater to your ActiveRecord objects
  track_who_does_it

  #constants
  UNIT = %w(Each Feet Kgs)
  TAX = %w(5 10 12 15 17)

  def self.search_box(search_text,current_user_id)
    search = where("categories.sales_user_id = ?",current_user_id)
    if !/\A\d+\z/.match(search_text)
      code = search_text.gsub(/\D/,'')
      if code.present?
        search = search.where(id: code.to_i)
      else
        search = search.where("name LIKE :search OR manufacturer LIKE :search
                OR description LIKE :search ", search: "%#{search_text}%")
      end
    else
      search = search.where("id :search OR unit :search
                OR tax :search ", search: "%#{search_text}%")
    end
    return search
  end

  def self.search(params,current_user_id)
    search = where("categories.sales_user_id = ?",current_user_id)
    search = search.where("categories.id = ?",params[:code].gsub(/\D/,'')) if params[:code].present?
    search = search.where('categories.name = ?',params[:name]) if params[:name].present?
    search = search.where('categories.unit = ?',params[:unit]) if params[:unit].present?
    search = search.where('categories.tax = ?',params[:tax]) if params[:tax].present?
    search = search.where('categories.manufacturer = ?',params[:manufacturer]) if params[:manufacturer].present?
    search = search.where('categories.description = ?',params[:description]) if params[:description].present?
    search = search.where('DATE(categories.created_at) = ?', params[:created_at].to_date) if params[:created_at].present?
    search = search.where('categories.created_by_id = ?',params[:created_by_id]) if params[:created_by_id].present?
    return search
  end

  def get_json_category
    as_json(only: [:id,:name,:unit,:tax,:manufacturer,:description])
    .merge({
      code:"CAT#{self.id.to_s.rjust(4, '0')}",
      created_at:self.created_at.strftime('%d %B, %Y'),
      created_by:self.creator.try(:full_name),
      updated_at:self.updated_at.strftime('%d %B, %Y'),
      updated_by:self.updater.try(:full_name),
      items: self.items.with_active.get_json_items
    })
  end 

  def self.get_json_categories
    categories_list =[]
    all.each do |category|
      categories_list << category.get_json_category
    end
    return categories_list
  end

  def self.sales_categories(current_user)
    where("categories.sales_user_id = ? AND categories.is_active = ?",current_user.id,true)
  end

  def self.get_json_categories_dropdown(categories)
    list = []
    categories.each do |category|
      list << as_json(only: [])
        .merge({name:category.name,
          category_id:category.id,
        })
    end
    return list
  end
end
