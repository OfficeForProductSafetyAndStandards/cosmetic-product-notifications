class ApplicationController < ActionController::Base
  include Shared::Web::Concerns::AuthenticationConcern

  include UserService
  helper Shared::Web::Engine.helpers
  helper_method :current_user, :user_signed_in?

  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :create_or_join_responsible_person

  def create_or_join_responsible_person
    return unless user_signed_in?

    redirect_to account_path(:create_or_join_existing) if current_user.responsible_persons.empty?
  end
end
