class ApplicationController < ActionController::Base
  include Shared::Web::Concerns::AuthenticationConcern

  helper Shared::Web::Engine.helpers

  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_current_user
  before_action :create_or_join_responsible_person

  def create_or_join_responsible_person
    return unless user_signed_in?

    redirect_to create_or_join_existing_account_index_path if User.current.responsible_persons.empty?
  end
end
