class Buyer < ActiveRecord::Base
  #Belongs To Relationship
  belongs_to :marketplace

  #Has Many Relationship
  has_many :orders
  has_many :order_shipping_details
end
