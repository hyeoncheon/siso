class UsersController < ApplicationController
  def photo
    @user = User.find(params[:id])
    send_data(@user.image,
              :filename => "profile.jpg",
              :type => "Image/Jpeg",
              :disposition => "inline")
  end

  def index
    if is_admin_session?
      @users = User.order('created_at asc')
    else
      flash[:error] = 'Only admin can access this.'
      @users = User.order('created_at asc')
      #redirect_to services_path
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end
end
# vim:set ts=2 sw=2 expandtab:
