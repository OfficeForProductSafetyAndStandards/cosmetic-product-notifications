class ApplicationController < ActionController::Base
  include Shared::Web::Concerns::AuthenticationConcern
  include Shared::Web::Concerns::CacheConcern
  include Shared::Web::Concerns::HttpAuthConcern
  include Shared::Web::Concerns::RavenConfigurationConcern

  helper Shared::Web::Engine.helpers

  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_current_user
  before_action :set_raven_context
  before_action :set_cache_headers

  before_action :authorize_user!
  before_action :has_accepted_declaration
  before_action :create_or_join_responsible_person

  add_flash_types :confirmation

private

  def authorize_user!
    raise Pundit::NotAuthorizedError if poison_centre_or_msa_user?
  end

  def has_accepted_declaration
    return unless user_signed_in?

    redirect_path = request.original_fullpath unless request.original_fullpath == root_path
    redirect_to declaration_path(redirect_path: redirect_path) unless User.current.has_accepted_declaration?
  end

  def create_or_join_responsible_person
    return unless user_signed_in? && !poison_centre_or_msa_user?

    if User.current.responsible_persons.empty?
      redirect_to account_path(:overview)
    elsif User.current.responsible_persons.first.contact_persons.none?(&:is_email_verified)
      responsible_person = User.current.responsible_persons.first
      redirect_to responsible_person_email_verification_keys_path(responsible_person)
    end
  end

  def poison_centre_or_msa_user?
    User.current&.poison_centre_user? || User.current&.msa_user?
  end
end
