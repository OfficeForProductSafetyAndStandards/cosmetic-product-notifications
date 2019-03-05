class ApplicationController < ActionController::Base
  include Shared::Web::Concerns::AuthenticationConcern
  include Shared::Web::Concerns::RavenConfigurationConcern

  helper Shared::Web::Engine.helpers

  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_current_user
  before_action :set_raven_context
  before_action :authorize_user

  def authorize_user
    raise Pundit::NotAuthorizedError unless User.current&.is_mspsds_user?
  end
end
