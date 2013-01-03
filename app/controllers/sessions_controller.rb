class SessionsController < ApplicationController
  def create
    render :xml => request.env['omniauth.auth'].to_xml
  end
end
