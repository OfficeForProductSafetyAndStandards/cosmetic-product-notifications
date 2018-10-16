class Investigations::ReportController < ApplicationController
  include Wicked::Wizard
  steps :type, :details

  # GET /investigations/report/new
  def new
    redirect_to report_index_path if request.get?
  end

  # POST /investigations/report
  def create
    update_partial_reporter
    @investigation = Investigation.new
    @investigation.reporter = @reporter
    @investigation.source = UserSource.new(user: current_user)
    @investigation.save
    redirect_to investigation_path(@investigation)
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
    @reporter = Reporter.new(session[:reporter].merge({step: step}))
      render step
    else
      redirect_to next_wizard_path if step != steps.last
      create if step == steps.last
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
    session[:reporter] = session[:reporter].merge(reporter_params)
    @reporter = Reporter.new(session[:reporter].merge(step: step))
    session[:reporter] = @reporter.attributes
  end
end
