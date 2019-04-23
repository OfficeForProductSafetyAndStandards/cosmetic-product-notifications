class ApplicationController < ActionController::Base
  include Shared::Web::Concerns::AuthenticationConcern
  include Shared::Web::Concerns::CacheConcern
  include Shared::Web::Concerns::HttpAuthConcern
  include Shared::Web::Concerns::RavenConfigurationConcern

  helper Shared::Web::Engine.helpers

  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_current_user
  before_action :set_raven_context
  before_action :authorize_user
  before_action :has_accepted_declaration
  before_action :set_cache_headers

  helper_method :nav_items, :secondary_nav_items

  def authorize_user
    raise Pundit::NotAuthorizedError unless User.current&.is_psd_user?
  end

  def has_accepted_declaration
    redirect_to declaration_index_path(redirect_path: request.original_fullpath) unless User.current.has_accepted_declaration
  end

  def hide_nav?
    false
  end

  def nav_items
    return nil if hide_nav? # On some pages we don't want to show the main navigation

    items = []
    unless User.current.is_opss?
      items.push text: "Home", href: root_path, active: params[:controller] == "homepage"
    end
    items.push text: "Cases", href: investigations_path, active: params[:controller].start_with?("investigations")
    items.push text: "Businesses", href: businesses_path, active: params[:controller].start_with?("businesses")
    items.push text: "Products", href: products_path, active: params[:controller].start_with?("products")
    # In principle all our users belong to a team, but this saves crashes in case of a misconfiguration
    if User.current.teams.present?
      text = User.current.teams.count > 1 ? "Your teams" : "Your team"
      path = User.current.teams.count > 1 ? your_teams_path : team_path(User.current.teams.first)
      items.push text: text, href: path, active: params[:controller].start_with?("teams"), right: true
    end
    items
  end

  def secondary_nav_items
    items = []
    items.push text: "Your account", href: Shared::Web::KeycloakClient.instance.user_account_url if User.current
    if User.current
      items.push text: "Sign out", href: shared_engine.logout_session_path
    else
      items.push text: "Sign in", href: keycloak_login_url
    end
    items
  end
end
