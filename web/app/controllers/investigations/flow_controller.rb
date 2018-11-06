class Investigations::FlowController < ApplicationController
  include Wicked::Wizard
  # Commonises report_controller and question_controller
  # xxx in paths can be 'report' or 'question'

  # GET /investigations/xxx/new
  def new
    clear_session
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  # POST /investigations/xxx
  def create
    load_reporter_and_investigation
    @investigation.reporter = @reporter
    @investigation.source = UserSource.new(user: current_user)
    @investigation.save
    AuditActivity::Report::Add.from(@reporter, @investigation)
  end

  # GET /investigations/xxx
  # GET /investigations/xxx/step
  def show
    load_reporter_and_investigation
    render_wizard
  end

  def load_reporter_and_investigation
    load_investigation
    load_reporter
  end

private

  def load_reporter
    data_from_the_past = session[:reporter] || {}
    data_after_last_step = data_from_the_past.merge(reporter_params)
    session[:reporter] = data_after_last_step
    @reporter = Reporter.new(session[:reporter])
  end

  def reporter_params
    return {} if params[:reporter].blank?

    handle_reporter_type
    params.require(:reporter).permit(
      :name, :phone_number, :email_address, :reporter_type, :other_details
    )
  end

  def handle_reporter_type
    if params[:reporter][:reporter_type] == 'Other'
      params[:reporter][:reporter_type] = params[:reporter][:other_reporter].presence || 'Other'
    end
    if params[:reporter][:reporter_type].blank?
      params[:reporter][:reporter_type] = 'Person'
    end
  end

  def clear_session
    session[:reporter] = nil
  end

  def load_investigation
    # default_investigation can be provided by the class using this helper
    # If it's not, then the one below is used
    @investigation = default_investigation
  end

  def default_investigation
    Investigation.new
  end
end
