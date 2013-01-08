class UsersController < ApplicationController
  def show_image
    @user = User.find(params[:id])
    send_data(@user.image,
              :filename => @user.id.to_s + ".jpg",
              :type => "Image/Jpeg",
              :disposition => "inline")
  end
end
