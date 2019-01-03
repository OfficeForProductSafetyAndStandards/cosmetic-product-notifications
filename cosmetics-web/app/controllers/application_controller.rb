class ApplicationController < ActionController::Base
  include Shared::Web::Concerns::AuthenticationConcern

  helper Shared::Web::Engine.helpers
  helper_method :user_signed_in?

  protect_from_forgery with: :exception
  before_action :authenticate_user!

  def current_user
    user_info = Shared::Web::KeycloakClient.instance.user_info
    User.find_or_create(user_info)
  end

end
