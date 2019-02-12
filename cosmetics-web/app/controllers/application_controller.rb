class ApplicationController < ActionController::Base
  include Shared::Web::Concerns::AuthenticationConcern

  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :forbidden

  include UserService
  helper Shared::Web::Engine.helpers
  helper_method :current_user, :user_signed_in?

  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :create_or_join_responsible_person

  def create_or_join_responsible_person
    return unless user_signed_in?

    redirect_to create_or_join_existing_account_index_path if current_user.responsible_persons.empty?
  end

  def forbidden
    render "errors/forbidden"
  end
end
