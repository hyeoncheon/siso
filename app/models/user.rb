class User < ActiveRecord::Base
  belongs_to :group
  has_many :services

  attr_accessible :active, :mail, :name
end
