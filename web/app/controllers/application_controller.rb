class ApplicationController < ActionController::Base
  include Shared::Web::Concerns::ApplicationConcern

  include Pundit
  helper Shared::Web::Engine.helpers
  helper_method :current_user, :user_signed_in?

  protect_from_forgery with: :exception
  before_action :set_raven_context
  before_action :authenticate_user!

  def set_raven_context
    Raven.user_context(id: current_user.id) if current_user
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
