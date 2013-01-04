class ServicesController < ApplicationController
  def create
    omniauth = request.env['omniauth.auth']
    ai = Hash.new # auth info
    ai[:provider] = omniauth['provider']

    logger.debug("current provider: --#{ai[:provider]}--")
    if ai[:provider].to_s == 'open_id'
      ai[:name] = omniauth['info']['name']
      ai[:mail] = omniauth['info']['email']
      ai[:uid] = omniauth['uid']
    end
    logger.debug("current mail: --#{ai[:mail]}--")

    unless @auth = Service.find_by_provider_and_uid(ai[:provider], ai[:uid])
      unless @user = User.find_by_mail(ai[:mail])
        # service and user not found. so register new user and service.
        user = Group.find_by_name('guest').users.create(:mail => ai[:mail])
        user.services.create(:uid => ai[:uid],
                             :provider => ai[:provider],
                             :smail => ai[:mail])
        logger.info("new service #{ai[:provider]} for #{user.mail}.")
        render :text => "new user #{user.mail} (#{user.id})"
      else
        # new service but user exist with same email.
        #logger.info("new user #{user.mail} (#{user.id})")
        render :text => "Auth service not exist but user exist."
      end
    else
      # already registered service so process login
      render :text => omniauth.to_yaml
    end
  end
end
# vim: set ts=2 sw=2 expandtab:
