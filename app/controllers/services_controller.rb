class ServicesController < ApplicationController
  def create
    omniauth = request.env['omniauth.auth']
    ai = Hash.new # auth info
    ai[:provider] = omniauth['provider']

    # XXX logger.debug(omniauth.to_yaml)
    logger.debug("DEBUG current provider: --#{ai[:provider]}--")
    logger.debug("DEBUG info: --#{omniauth.to_xml}--")
    if ai[:provider].to_s == 'open_id'
      ai[:name] = omniauth['info']['name']
      ai[:mail] = omniauth['info']['email']
      ai[:uid] = omniauth['uid']
    elsif ai[:provider].to_s == 'ldap'
      # custom of cc-ad.
      ai[:uid] = omniauth['extra']['raw_info']['employeenumber'].first
      ai[:name] = omniauth['extra']['raw_info']['extensionattribute10'].first
      ai[:mail] = omniauth['info']['email']
      ai[:image] = omniauth['extra']['raw_info']['thumbnailphoto'].first
      ai[:phone] = omniauth['info']['phone']
      ai[:mobile] = omniauth['info']['mobile']
      logger.debug("ldap user - uid: #{ai[:uid]} name: #{ai[:name]}")
    elsif ai[:provider].to_s == 'facebook'
      ai[:uid] = omniauth['uid']
      ai[:name] = omniauth['info']['name']
      ai[:mail] = omniauth['info']['email']
      ai[:image] = omniauth['info']['image']
    end
    logger.debug("DEBUG current mail: --#{ai[:mail]}--")
    if ai[:mail] == nil or ai[:mail] == ''
      flash[:error] = "authentication error! no mail address found."
      redirect_to root_path
      return
    end

    unless @auth = Service.find_by_provider_and_uid(ai[:provider], ai[:uid])
      unless user = User.find_by_mail(ai[:mail])
        # service and user not found. so register new user and service.
        user = Group.find_by_name('guest').users.create(:mail => ai[:mail])
        user.update_attributes(:name => ai[:name],
                               :image => ai[:image],
                               :phone => ai[:phone],
                               :mobile => ai[:mobile])
        if User.count == 1
          user.update_attributes(:group_id => Group.find_by_name('admin').id,
                                 :active => true)
          flash[:notice] = "The 'one and only' user #{user.mail}" +
            " registered and auto activated!" +
            " You are Super User for this site!"
        else
          flash[:notice] = "New user #{user.mail} signin via #{ai[:provider]}."
        end
      else
        flash[:notice] = "add new authentication service for existing user."
      end
      @auth = user.services.create(:uid => ai[:uid],
                                   :provider => ai[:provider],
                                   :sname => ai[:name],
                                   :smail => ai[:mail])
    else
      flash[:notice] = "welcome! #{@auth.user.mail} (from #{@auth.provider})"
      # update service information automatically. is it right?
      @auth.update_attributes(:sname => ai[:name], :smail => ai[:mail])
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
      @applications = Doorkeeper::Application.authorized_for(current_user)
    else
      @services = []
      @applications = []
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
