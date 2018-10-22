class Investigations::QuestionController < ApplicationController
  include Wicked::Wizard
  steps :questioner_type, :questioner_details, :question_details, :confirmation

  # GET /investigations/report/new
  def new
    session[:reporter] = {}
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  # POST /investigations/report
  def create
    load_reporter_and_investigation
    session[:reporter] = {}
    @investigation.reporter = @reporter
    @investigation.source = UserSource.new(user: current_user)
    @investigation.save
    session[:id] = @investigation.id
  end

  # GET /investigations/report
  # GET /investigations/report/step
  def show
    load_reporter_and_investigation
    render_wizard
  end

  def update
    load_reporter_and_investigation
    case step
    when :questioner_type, :questioner_details
      return render step if !@reporter.valid?(step)
    when :question_details
      return render step if !@investigation.valid?(step)
      create
    end
    redirect_to next_wizard_path
  end

private

  def reporter_params
    return {} if !params[:reporter] || params[:reporter] == {}
    if params[:reporter][:reporter_type] == 'Other'
      params[:reporter][:reporter_type] = params[:reporter][:other_reporter]
    end
    params.require(:reporter).permit(
      :name, :phone_number, :email_address, :reporter_type, :other_details
    )
  end

  def investigation_params
    return {} if !params[:investigation]
    if params[:investigation][:question_type] == 'other_question'
      params[:investigation][:question_type] = 'other_question: ' + params[:investigation][:other_question_type]
    end
    params.require(:investigation).permit(
      :title, :description, :question_type
    )
  end

  def load_reporter_and_investigation
    load_investigation
    load_reporter
  end

  def load_reporter
    data_from_database = @investigation.reporter&.attributes || {}
    data_from_previous_steps = data_from_database.merge(session[:reporter] || {})
    data_after_last_step = data_from_previous_steps.merge(params[:reporter]&.permit! || {})
    params[:reporter] = data_after_last_step
    session[:reporter] = reporter_params
    @reporter = Reporter.new(session[:reporter])
  end

  def load_investigation
    # TODO figure out if we ever need more than that here, as in, is this controller going to be used to edit question
    @investigation = Investigation.new(investigation_params)
    @investigation.is_case = false
  end

end
