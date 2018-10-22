class Investigations::ReportController < ApplicationController
  include ReporterHelper
  include Wicked::Wizard
  steps :type, :details, :confirmation

  # GET /investigations/report/new
  def new
    clear_session
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  # POST /investigations/report
  def create
    load_reporter_and_investigation
    @investigation.reporter = @reporter
    @investigation.source = UserSource.new(user: current_user)
    @investigation.save
    session[:investigation_id] = @investigation.id
  end

  # GET /investigations/report
  # GET /investigations/report/step
  def show
    load_reporter_and_investigation
    render_wizard
  end

  def update
    load_reporter_and_investigation
    if !@reporter.valid?(step)
      render step
    else
      create if next_step? :confirmation
      clear_session if step == :confirmation
      redirect_to next_wizard_path
    end
  end

private

  def load_investigation
    if session[:investigation_id]
      @investigation = Investigation.find_by(id: session[:investigation_id])
    else
      @investigation = Investigation.new
      @investigation.is_case = true
    end
  end

  def clear_session
    session[:reporter] = {}
    session[:investigation_id] = nil
  end
end
