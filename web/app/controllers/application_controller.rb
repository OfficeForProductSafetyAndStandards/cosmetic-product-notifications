class ApplicationController < Shared::Web::ApplicationController
  include Pundit
  before_action :set_raven_context

  def set_raven_context
    Raven.user_context(id: current_user.id) if current_user
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
