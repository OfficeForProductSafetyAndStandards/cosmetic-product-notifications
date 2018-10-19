class Investigations::QuestionController < ApplicationController
  include Wicked::Wizard
  steps :questioner_type, :questioner_details, :question_details

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
    redirect_to investigation_url(@investigation)
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
      redirect_to next_wizard_path
    when :question_details
      return render step if !@investigation.valid?(step)
      create
    end
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
    params.require(:investigation).permit(
      :title, :description, :object_type
    )
  end

  def load_reporter_and_investigation
    load_investigation
    load_reporter

    @investigation = Investigation.new(investigation_params)
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
    @investigation = Investigation.new(investigation_params)
  end

end
