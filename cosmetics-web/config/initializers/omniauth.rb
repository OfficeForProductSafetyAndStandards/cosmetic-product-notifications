Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect, {
    name: :one_login,
    scope: [:openid, :email],
    response_type: :code,

    token_endpoint_auth_method: 'private_key_jwt',
    client_signing_alg: 'RS256',
    client_jwk_signing_key: Rails.application.credentials[:one_login_jwk],

    client_options: {
      identifier: ENV['ONELOGIN_CLIENT_ID'],
      redirect_uri: ENV['ONELOGIN_REDIRECT_URI'],

      scheme: 'https',
      host: 'oidc.integration.account.gov.uk'
    }
  }
end