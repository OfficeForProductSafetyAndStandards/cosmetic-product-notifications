class Investigations::ReportController < ApplicationController
  include Wicked::Wizard
  steps :type, :details, :confirmation

  # GET /investigations/report/new
  def new
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  # POST /investigations/report
  def create
    update_partial_reporter
    session[:reporter] = {}
    @investigation = Investigation.new
    @investigation.is_case = true
    @investigation.reporter = @reporter
    @investigation.source = UserSource.new(user: current_user)
    @investigation.save
    session[:id] = @investigation.id
  end

  # GET /investigations/report
  # GET /investigations/report/step
  def show
    session[:reporter] = {} if step == steps.first
    @reporter = Reporter.new(session[:reporter])
    render_wizard
  end

  def update
    update_partial_reporter
    if !@reporter.valid?(step)
      render step
    else
      create if next_step? :confirmation
      redirect_to next_wizard_path
    end
  end

private

  def reporter_params
    if params[:reporter][:reporter_type] == 'Other'
      params[:reporter][:reporter_type] = params[:reporter][:other_reporter]
    end
    params.require(:reporter).permit(
      :name, :phone_number, :email_address, :reporter_type, :other_details
    )
  end

  def update_partial_reporter
    session[:reporter] = (session[:reporter] || {}).merge(reporter_params)
    @reporter = Reporter.new(session[:reporter])
    session[:reporter] = @reporter.attributes
  end
end
