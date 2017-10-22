class InventoryItem < ActiveRecord::Base
  belongs_to :item_category
  belongs_to :item_source
  has_many :listings
end
