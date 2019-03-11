class ErrorsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :authorize_user!
  skip_before_action :create_or_join_responsible_person

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
end
