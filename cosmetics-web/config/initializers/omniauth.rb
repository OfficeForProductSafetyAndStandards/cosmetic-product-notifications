Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect, {
    name: :one_login,
    scope: %i[openid email],
    response_type: :code,
    client_options: {
      identifier: ENV["ONELOGIN_CLIENT_ID"],
      secret: ENV["ONELOGIN_CLIENT_SECRET"],
      redirect_uri: ENV["ONELOGIN_REDIRECT_URI"],
      host: ENV["ONELOGIN_HOST_URI"],
      scheme: "https",
    },
  }
end
