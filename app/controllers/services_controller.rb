class ServicesController < ApplicationController
  def create
    omniauth = request.env['omniauth.auth']
    ai = Hash.new # auth info
    ai[:provider] = omniauth['provider']

    #logger.debug(omniauth.to_yaml)
    logger.debug("DEBUG current provider: --#{ai[:provider]}--")
    if ai[:provider].to_s == 'open_id'
      ai[:name] = omniauth['info']['name']
      ai[:mail] = omniauth['info']['email']
      ai[:uid] = omniauth['uid']
    elsif ai[:provider].to_s == 'ldap'
      # custom of cc-ad.
      ai[:uid] = omniauth['extra']['raw_info']['employeenumber']
      ai[:name] = omniauth['extra']['raw_info']['extensionattribute10']
      ai[:mail] = omniauth['info']['email']
      ai[:image] = omniauth['extra']['raw_info']['thumbnailphoto']
      ai[:phone] = omniauth['info']['phone']
      ai[:mobile] = omniauth['info']['mobile']
    end
    logger.debug("DEBUG current mail: --#{ai[:mail]}--")

    unless @auth = Service.find_by_provider_and_uid(ai[:provider], ai[:uid])
      unless @user = User.find_by_mail(ai[:mail])
        # service and user not found. so register new user and service.
        user = Group.find_by_name('guest').users.create(:mail => ai[:mail])
        @auth = user.services.create(:uid => ai[:uid],
                                     :provider => ai[:provider],
                                     :smail => ai[:mail])

        flash[:notice] = "New user #{user.mail} signin via #{ai[:provider]}."
      else
        flash[:error] = "new authentication for existing user."
      end
    else
      flash[:notice] = "welcome! #{@auth.user.mail} (from #{@auth.provider})"
    end
    session[:user] = @auth.user.id
    session[:name] = @auth.user.name
    session[:mail] = @auth.user.mail
    session[:auth] = @auth.id

    logger.debug("DEBUG cookie_origin: #{cookies[:siso_oauth_origin]}")
    next_path = cookies[:siso_oauth_origin] || services_path
    cookies.delete :siso_oauth_origin
    redirect_to next_path
  end

  def index
    if current_user
      @services = current_user.services.order('provider asc')
    else
      @services = []
    end
  end

  def signout
    if current_user
      session[:user] = nil
      session[:auth] = nil
      session.delete :user
      session.delete :auth
      flash[:notice] = "successfully signed out!"
    end
    redirect_to services_path
  end

  def failure
    flash[:error] = "Authentication error!"
    redirect_to services_path
  end

  def destroy
    @service = current_user.services.find(params[:id])
    if session[:auth] == @service.id
      flash[:error] = "You are currently signed in with this account!"
    else
      @service.destroy
    end
    redirect_to services_path
  end
end
# vim: set ts=2 sw=2 expandtab:
