class ItemCategory < ActiveRecord::Base
	has_many :inventory_items, :dependent => :restrict_with_exception
  	has_many :listings, :dependent => :restrict_with_exception
end
