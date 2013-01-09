class User < ActiveRecord::Base
  belongs_to :group
  has_many :services

  include Gravtastic
  is_gravtastic :mail, :size => 48, :filetype => :png

  attr_accessible :active, :mail, :name
  attr_accessible :image, :mobile, :phone
  attr_accessible :group_id
end
