class ApplicationController < ActionController::Base
  include Shared::Web::Concerns::ApplicationConcern
  helper Shared::Web::Engine.helpers
  helper_method :current_user, :user_signed_in?

  protect_from_forgery with: :exception
  before_action :authenticate_user!
end
