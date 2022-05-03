class ErrorsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :authorize_user!

  def not_found
    render status: :not_found, formats: [:html]
  end

  def internal_server_error
    render status: :internal_server_error, formats: [:html]
  end

  def timeout
    render :internal_server_error, status: :service_unavailable, formats: [:html]
  end

  def forbidden
    render status: :forbidden, formats: [:html]
  end

  def invalid_account
    template = search_domain? ? :wrong_service_for_submit_user : :wrong_service_for_search_user
    render template, status: :forbidden, formats: [:html], locals: { user_role: current_user&.role }
  end
end
