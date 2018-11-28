class Create::CreationFlowController < ApplicationController
  include Wicked::Wizard

  # GET /create/xxx
  # GET /create/xxx/step
  def show
    render_wizard
  end

  # GET /create/xxx/new
  def new
    clear_session
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

private

  def clear_session
    session[:reporter] = nil
  end

  def set_reporter
    @reporter = Reporter.new(reporter_params)
  end

  def store_reporter
    session[:reporter] = @reporter.attributes if @reporter.valid?(step)
  end

  def reporter_params
    reporter_session_params.merge(reporter_request_params)
  end

  def reporter_session_params
    session[:reporter] || {}
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def reporter_request_params
    return {} if params[:reporter].blank?

    params.require(:reporter).permit(:reporter_type, :name, :phone_number, :email_address, :other_details)
  end
end
