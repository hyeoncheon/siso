class UsersController < ApplicationController
  def photo
    @user = User.find(params[:id])
    send_data(@user.image,
              :filename => "profile.jpg",
              :type => "Image/Jpeg",
              :disposition => "inline")
  end
end
