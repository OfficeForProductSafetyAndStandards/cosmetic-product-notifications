class ErrorsController < ApplicationController
  skip_before_action :authenticate_user!

  def forbidden
    render status: :forbidden, formats: [:html]
  end
end
