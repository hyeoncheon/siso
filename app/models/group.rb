class Group < ActiveRecord::Base
  has_many :users

  attr_accessible :active, :name
end
