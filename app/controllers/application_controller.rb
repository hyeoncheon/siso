class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user
  helper_method :user_signed_in?
  helper_method :is_admin_session?

  private
    def current_user
      logger.debug("current_user form session: #{session[:user].to_s}")
      @current_user ||= User.find_by_id(session[:user]) if session[:user]
    end

    def user_signed_in?
      return 1 if current_user
    end

    def is_admin_session?
      return 1 if current_user and current_user.group.name == 'admin'
    end
end
# vim: set ts=2 sw=2 expandtab:
