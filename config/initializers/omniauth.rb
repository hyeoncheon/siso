Rails.application.config.middleware.use OmniAuth::Builder do
  require 'openid/store/filesystem'
  provider :openid, :store => OpenID::Store::Filesystem.new('/tmp')
  provider :ldap,
    :title => 'EXAMPLE.NET',
    :host => 'ldap.example.net',
    :port => 389,
    :method => :plain,
    :base => 'ou=Humans,dc=example,dc=net',
    :uid => 'mail',
    :password => 'bind_dn_s_password_here',
    :try_sasl => false,
    :bind_dn => 'admin@example.net'
end

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
