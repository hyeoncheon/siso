class UsersController < ApplicationController
  before_filter :login_required

  def photo
    @user = User.find(params[:id])
    if @user.image
      if @user.image.isutf8
        redirect_to @user.image
      else
        send_data(@user.image,
                  :filename => "profile-#{@user.id}.jpg",
                  :type => "Image/Jpeg",
                  :disposition => "inline")
      end
    else
      # default image
      redirect_to ActionController::Base.helpers.asset_path('user-black.png')
    end
  end

  def index
    if is_admin_session?
      @users = User.order('created_at asc')
    else
      flash[:error] = 'Only admin can access this.'
      redirect_to services_path
    end
  end
end
# vim:set ts=2 sw=2 expandtab:
