class ItemSource < ActiveRecord::Base
	has_many :inventory_items, :dependent => :nullify
end
