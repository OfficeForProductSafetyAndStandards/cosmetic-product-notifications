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

  helper_method :hide_nav?

  def authorize_user
    raise Pundit::NotAuthorizedError unless User.current&.is_psd_user?
  end

  def has_accepted_declaration
    redirect_to declaration_index_path(redirect_path: request.original_fullpath) unless User.current.has_accepted_declaration
  end

  def hide_nav?
    false
  end
end
