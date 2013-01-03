class User < ActiveRecord::Base
  belongs_to :group
  attr_accessible :active, :mail, :name
end
