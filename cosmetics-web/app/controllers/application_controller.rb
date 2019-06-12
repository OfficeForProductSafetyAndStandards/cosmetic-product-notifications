class ApplicationController < ActionController::Base
  include Shared::Web::Concerns::AuthenticationConcern
  include Shared::Web::Concerns::CacheConcern
  include Shared::Web::Concerns::HttpAuthConcern
  include Shared::Web::Concerns::RavenConfigurationConcern
  include DomainConcern

  helper Shared::Web::Engine.helpers

  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_current_user
  before_action :set_raven_context
  before_action :set_cache_headers
  before_action :set_service_name

  before_action :authorize_user!
  before_action :has_accepted_declaration
  before_action :create_or_join_responsible_person

  helper_method :search_domain_url, :submit_domain_url

  add_flash_types :confirmation

private

  def authorize_user!
    return unless user_signed_in?

    incorrect_domain = (submit_domain? && poison_centre_or_msa_user?) || (search_domain? && !poison_centre_or_msa_user?)
    redirect_to(invalid_account_path) if incorrect_domain
  end

  def has_accepted_declaration
    return unless user_signed_in?

    redirect_path = request.original_fullpath unless request.original_fullpath == root_path
    redirect_to declaration_path(redirect_path: redirect_path) unless User.current.has_accepted_declaration?
  end

  def create_or_join_responsible_person
    return unless user_signed_in? && !poison_centre_or_msa_user?

    responsible_person = User.current.responsible_persons.first

    if responsible_person.blank?
      redirect_to account_path(:overview)
    elsif responsible_person.contact_persons.empty?
      redirect_to new_responsible_person_contact_person_path(responsible_person)
    elsif responsible_person.contact_persons.none?(&:email_verified?)
      contact_person = responsible_person.contact_persons.first
      redirect_to responsible_person_contact_person_path(responsible_person, contact_person)
    end
  end

  def poison_centre_or_msa_user?
    User.current&.poison_centre_user? || User.current&.msa_user?
  end
end
