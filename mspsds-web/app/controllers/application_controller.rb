class ApplicationController < ActionController::Base
  include Shared::Web::Concerns::AuthenticationConcern

  include Pundit
  include UserService
  helper Shared::Web::Engine.helpers
  helper_method :current_user, :user_signed_in?

  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_raven_context

  def set_raven_context
    Raven.user_context(id: current_user.id) if user_signed_in?
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
