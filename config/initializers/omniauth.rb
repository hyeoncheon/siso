Rails.application.config.middleware.use OmniAuth::Builder do
  require 'openid/store/filesystem'
  provider :openid, :store => OpenID::Store::Filesystem.new('/tmp/siso')
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'],
    { scope: 'public_profile,email', info_fields: 'email,name,verified' }
end

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}

OmniAuth.config.logger = Rails.logger
OmniAuth.config.path_prefix = '/siso/auth'
OmniAuth.config.form_css = '@import url("/siso/assets/omniauth.css");'
