class ItemImage < ActiveRecord::Base
  mount_uploader :image, AvatarUploader

  #Belongs To Relationship
  belongs_to :item
end
