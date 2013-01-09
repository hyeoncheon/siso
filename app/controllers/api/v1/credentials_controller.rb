module Api::V1
  class CredentialsController < ApiController
    doorkeeper_for :all

    respond_to :json

    def me
      user = current_resource_owner
      user.image = request.protocol + request.env['HTTP_HOST'] +
        photo_user_path(user.id)
      respond_with user
    end
  end
end
