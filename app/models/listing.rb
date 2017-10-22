class Listing < ActiveRecord::Base
	belongs_to :user
  # belongs_to :item_category
  belongs_to :inventory_item
  has_many :images, -> { order(:sort_order) }, :class_name => 'ListingImage', :inverse_of => :listing, :dependent => :destroy
end
