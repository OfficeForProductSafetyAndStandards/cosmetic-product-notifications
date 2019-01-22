class ApplicationController < ActionController::Base
  include Shared::Web::Concerns::AuthenticationConcern

  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :forbidden

  include UserService
  helper Shared::Web::Engine.helpers
  helper_method :current_user, :user_signed_in?

  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_raven_context
  before_action :authorize_user

  def authorize_user
    return unless user_signed_in?

    unless current_user&.is_mspsds_user?
      raise Pundit::NotAuthorizedError
    end
  end

  def set_raven_context
    Raven.user_context(id: current_user.id) if user_signed_in?
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def forbidden
    redirect_to '/403'
  end
end
