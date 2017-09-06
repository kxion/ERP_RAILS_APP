class Item < ActiveRecord::Base
  #Belongs To Relationship
  belongs_to :category
  belongs_to :supplier

  #Has Many Relationship
  has_many :manufacturings
  has_many :purchase_orders
  has_many :warehouse_location
  has_many :item_images, dependent: :destroy

  #Scope For the Active Record
  scope :with_active, -> { where('is_active = ?', true) }
  
  #Creator,Updater to your ActiveRecord objects
  track_who_does_it

  def self.search_box(search_text,current_user_id)
    search = where("items.sales_user_id = ?",current_user_id)
    if !/\A\d+\z/.match(search_text)
      code = search_text.gsub(/\D/,'')
      if code.present?
        search = search.where(id: code.to_i)
      else
        search = search.where("name LIKE :search", search: "%#{search_text}%")
      end
    else
      search = search.where("category_id :search OR supplier_id :search", search: "%#{search_text}%")
    end
    return search
  end

  def self.search(params,current_user_id)
    search = where("items.sales_user_id = ?",current_user_id)
    search = search.where("items.id = ?",params[:code].gsub(/\D/,'')) if params[:code].present?
    search = search.where('items.name = ?',params[:name]) if params[:name].present?
    search = search.where('items.category_id = ?',params[:category_id]) if params[:category_id].present?
    search = search.where('items.supplier_id = ?',params[:supplier_id]) if params[:supplier_id].present?
    return search
  end

  def get_json_item
    purchase_order_ids= PurchaseOrderItem.where(item_id:self.id).pluck(:purchase_order_id)
    warehouse_location_item_ids= WarehouseLocationItem.where(item_id:self.id).pluck(:warehouse_location_id)
    as_json(only: [:id,:name,:unit,:selling_price,:purchase_price,:item_description,
      :purchase_description, :selling_description, :tax, :item_in_stock,
      :max_level, :min_level,:category_id,:supplier_id])
    .merge({
      code:"ITEM#{self.id.to_s.rjust(4, '0')}",
      category: self.category.try(:name),
      supplier: self.supplier.try(:user).try(:full_name),
      created_at:self.created_at.strftime('%d %B, %Y'),
      created_by:self.creator.try(:full_name),
      updated_at:self.updated_at.strftime('%d %B, %Y'),
      updated_by:self.updater.try(:full_name),
      purchase_orders: PurchaseOrder.with_active.where("id IN (?)",purchase_order_ids).get_json_purchase_orders,
      warehouse_locations: WarehouseLocation.with_active.where("id IN (?)",warehouse_location_item_ids).get_json_warehouse_locations,         
    })
  end 

  def self.get_json_items
    items_list =[]
    all.each do |item|
      items_list << item.get_json_item
    end
    return items_list
  end

  def self.sales_items(current_user)
      where("items.sales_user_id = ? AND items.is_active = ?",current_user.id,true)
  end

  def self.get_json_items_dropdown(items)
    list = []
    items.each do |item|
      list << as_json(only: [])
      .merge({name:item.name,
        items_id:item.id,
        unit:item.unit,
        item_in_stock:item.item_in_stock,
      })
    end
    return list
  end
end