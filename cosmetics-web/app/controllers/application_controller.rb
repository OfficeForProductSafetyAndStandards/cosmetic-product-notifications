class ApplicationController < ActionController::Base
  include Shared::Web::Concerns::AuthenticationConcern
  include HttpAuthConcern

  helper Shared::Web::Engine.helpers

  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_current_user
  before_action :create_or_join_responsible_person

  def create_or_join_responsible_person
    return unless user_signed_in?

    if current_user.responsible_persons.empty?
      redirect_to create_or_join_existing_account_index_path
    elsif current_user.responsible_persons.none?(&:is_email_verified)
      responsible_person = current_user.responsible_persons.first
      redirect_to responsible_person_email_verification_keys_path(responsible_person)
    end
  end
end
