class SalesOrderItem < ActiveRecord::Base
  #Belongs To Relationship
  belongs_to :sales_orders

  def get_json_sales_order_items_index
    as_json(only: [:id,:item_price,:quantity])
  end 

  def self.get_json_sales_order_items(is_items_index=true, items=[])
    items = all if is_items_index.present?
    items_list =[]
    items.each do |item|
      items_list << item.get_json_sales_order_items_index
    end
    return items_list
  end
end