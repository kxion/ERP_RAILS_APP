class PurchaseOrderItem < ActiveRecord::Base
  #Belongs To Relationship
  belongs_to :item
  belongs_to :purchase_order

  def get_json_item_purchase_order
    as_json(only: [:id,:purchase_order_id,:item_id,:quantity,:total,:unit_price])
    .merge({
      code:"ITEM#{self.id.to_s.rjust(4, '0')}",
      name: self.item.try(:name),
    })
  end 

  def self.get_json_item_purchase_orders
    purchase_order_items_list =[]
    all.each do |item_purchase_order|
      purchase_order_items_list << item_purchase_order.get_json_item_purchase_order
    end
    return purchase_order_items_list
  end
end