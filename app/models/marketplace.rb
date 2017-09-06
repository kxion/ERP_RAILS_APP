class Marketplace < ActiveRecord::Base
  #Has Many Relationship
  has_many :buyers
  has_many :accounts
end
