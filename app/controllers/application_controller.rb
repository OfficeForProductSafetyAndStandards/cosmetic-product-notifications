class ApplicationController < ActionController::Base
  include HttpAuthConcern
  include Pundit
  protect_from_forgery with: :exception

  before_action :set_paper_trail_whodunnit

  helper_method :current_user, :user_signed_in?

  def initialize
    Keycloak.proc_cookie_token = lambda do
      cookies.permanent[:keycloak_token]
    end

    super
  end

  def current_user
    return unless Keycloak::Client.user_signed_in?
    @current_user ||= User.new
  end

  def authenticate_user!
    redirect_to sessions_new_path unless user_signed_in?
  end

  def user_signed_in?
    Keycloak::Client.user_signed_in? || keycloak_controller?
  end

  private

  def keycloak_controller?
    Keycloak.keycloak_controller == controller_name
  end
end
