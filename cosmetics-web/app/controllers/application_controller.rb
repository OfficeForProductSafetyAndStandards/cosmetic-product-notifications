class ApplicationController < ActionController::Base
  include AuthenticationConcern
  include CacheConcern
  include HttpAuthConcern
  include RavenConfigurationConcern
  include DomainConcern
  include SecondaryAuthenticationConcern

  protect_from_forgery with: :exception
  before_action :authorize_user!
  before_action :authenticate_user!
  before_action :ensure_secondary_authentication
  before_action :require_secondary_authentication
  before_action :set_raven_context
  before_action :set_cache_headers
  before_action :set_service_name

  add_flash_types :confirmation

  helper_method :current_user

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from "ActiveRecord::RecordNotFound" do |_e|
    redirect_to "/404", status: :not_found
  end

  def user_params_key
    submit_domain? ? :submit_user : :search_user
  end

protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name mobile_number])
  end

private

  def user_class
    if params.key?("search_user")
      return SearchUser
    elsif params.key?("submit_user")
      return SubmitUser
    end

    raise ArgumentError
  end

  def user_param_key
    user_class.name.underscore.to_sym
  end

  def dig_params(param)
    params.dig(user_param_key, param)
  end

  def after_sign_in_path_for(_resource)
    submit_domain? ? dashboard_path : poison_centre_notifications_path
  end

  def authorize_user!
    return unless user_signed_in?

    redirect_to invalid_account_path if invalid_account_for_domain?
  end

  def has_accepted_declaration
    return unless user_signed_in?
    return unless current_user.mobile_number_verified?

    redirect_path = request.original_fullpath unless request.original_fullpath == root_path

    redirect_to declaration_path(redirect_path: redirect_path) unless current_user.has_accepted_declaration?
  end

  def poison_centre_or_msa_user?
    current_user&.poison_centre_user? || current_user&.msa_user?
  end

  def invalid_account_for_domain?
    (submit_domain? && current_search_user) || (search_domain? && current_submit_user)
  end

  def current_user
    submit_domain? ? current_submit_user : current_search_user
  end

  def user_signed_in?
    submit_user_signed_in? || search_user_signed_in?
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

  def user_password_path
    submit_domain? ? submit_user_password_path : search_user_password_path
  end
  helper_method :user_password_path
end
