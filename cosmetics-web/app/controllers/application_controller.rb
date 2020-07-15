class ApplicationController < ActionController::Base
  include AuthenticationConcern
  include CacheConcern
  include HttpAuthConcern
  include RavenConfigurationConcern
  include DomainConcern

  protect_from_forgery with: :exception
  before_action :authenticate_user!
  # before_action :set_raven_context TODO
  before_action :set_cache_headers
  before_action :set_service_name

  before_action :authorize_user!
  before_action :has_accepted_declaration
  before_action :create_or_join_responsible_person

  add_flash_types :confirmation

  helper_method :current_user

private

  def after_sign_in_path_for(_resource)
    dashboard_path
  end

  def authorize_user!
    return unless user_signed_in?

    redirect_to invalid_account_path if invalid_account_for_domain?
  end

  def has_accepted_declaration
    return unless user_signed_in?

    redirect_path = request.original_fullpath unless request.original_fullpath == root_path

    redirect_to declaration_path(redirect_path: redirect_path) unless current_user.has_accepted_declaration?
  end

  def create_or_join_responsible_person
    return unless user_signed_in? && !poison_centre_or_msa_user?

    responsible_person = current_user.responsible_persons.first

    if responsible_person.blank?
      redirect_to account_path(:overview)
    elsif responsible_person.contact_persons.empty?
      redirect_to new_responsible_person_contact_person_path(responsible_person)
    end
  end

  def poison_centre_or_msa_user?
    return false # TODO
    current_user&.poison_centre_user? || current_user&.msa_user?
  end

  def invalid_account_for_domain?
    (submit_domain? && poison_centre_or_msa_user?) || (search_domain? && !poison_centre_or_msa_user?)
  end

  def current_user
    submit_domain? ? current_submit_user : current_search_user
  end

  def user_signed_in?
    submit_domain? ? submit_user_signed_in? : search_user_signed_in?
  end

  def new_user_session_path(*args)
    submit_domain? ? new_submit_user_session_path(*args) : new_search_user_session_path(*args)
  end
  helper_method :new_user_session_path

  def authenticate_user!
    submit_domain? ? authenticate_submit_user! : authenticate_search_user!
  end

  def destroy_user_session_path
    submit_domain? ? destroy_submit_user_session_path : destroy_search_user_session_path
  end
  helper_method :destroy_user_session_path

  def user_session_path
    submit_domain? ? submit_user_session_path : search_user_session_path
  end
  helper_method :user_session_path

  def user_registration_path
    submit_domain? ? submit_user_registration_path : search_user_registration_path
  end
  helper_method :user_registration_path
end
