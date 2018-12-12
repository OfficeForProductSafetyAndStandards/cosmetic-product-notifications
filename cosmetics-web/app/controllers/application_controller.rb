class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  before_action :authenticate_user!
  helper_method :current_user, :user_signed_in?

  def initialize
    Keycloak.proc_cookie_token = lambda do
      cookies.permanent[:keycloak_token]
    end

    super
  end

  def current_user
    return unless Shared::Web::KeycloakClient.instance.user_signed_in?

    @current_user ||= find_or_create_user
  end

  def user_signed_in?
    Shared::Web::KeycloakClient.instance.user_signed_in?
  end

  def authenticate_user!
    redirect_to helpers.keycloak_login_url unless user_signed_in? || try_refresh_token
  end

  private

  def find_or_create_user
    user = Shared::Web::KeycloakClient.instance.user_info
    User.find_or_create(user)
  end

  def try_refresh_token
    begin
      cookies.permanent[:keycloak_token] = { value: Shared::Web::KeycloakClient.instance.refresh_token, httponly: true }
    rescue StandardError => error
      if error.is_a? Keycloak::KeycloakException
        raise
      else
        false
      end
    end
  end
end
