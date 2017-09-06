class OrderShippingDetail < ActiveRecord::Base
  #Belongs To Relationship
  belongs_to :buyer
  
  #Has One Relationship
  has_one :sales_orders
end
