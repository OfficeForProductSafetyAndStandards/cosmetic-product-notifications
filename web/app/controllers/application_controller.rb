class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :set_raven_context

  helper_method :current_user, :user_signed_in?

  def initialize
    Keycloak.proc_cookie_token = lambda do
      cookies.permanent[:keycloak_token]
    end

    super
  end

  def current_user
    return unless KeycloakClient.instance.user_signed_in?

    @current_user ||= find_or_create_user
  end

  def user_signed_in?
    KeycloakClient.instance.user_signed_in?
  end

  def authenticate_user!
    redirect_to helpers.keycloak_login_url unless user_signed_in? || try_refresh_token
  end

  def set_raven_context
    Raven.user_context(id: current_user.id) if current_user
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

private

  def find_or_create_user
    user = KeycloakClient.instance.user_info
    User.find_or_create(user)
  end

  def try_refresh_token
    begin
      cookies.permanent[:keycloak_token] = KeycloakClient.instance.refresh_token
    rescue StandardError => error
      if error.is_a? Keycloak::KeycloakException
        raise
      else
        false
      end
    end
  end
end
