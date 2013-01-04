class Service < ActiveRecord::Base
  belongs_to :user

  attr_accessible :provider, :smail, :sname, :uid
end
