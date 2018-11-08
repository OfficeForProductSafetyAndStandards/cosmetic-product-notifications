class Investigations::Hazards::FlowController < ApplicationController
  include FileConcern
  include Wicked::Wizard
  steps :details, :summary
  before_action :load_relevant_objects, only: %i[show update create]

  def new
    clear_session
    initialize_file_attachment
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  def create
    attach_file_to_attachment_slot(@file, @hazard.risk_assessment)
    @investigation.hazard = @hazard
    @investigation.save
    activity = create_hazard_audit_activity
    attach_file_to_attachment_slot(@file, activity.risk_assessment)
    redirect_to @investigation, notice: success_notice
  end

  def show
    render_wizard
  end

  def update
    if @hazard.invalid?
      render step
    else
      redirect_to next_wizard_path
    end
  end

  private

  def load_relevant_objects
    @investigation = Investigation.find_by(id: params[:investigation_id])
    @file = load_file_attachment
    set_hazard_data(@investigation)
  end

  def set_hazard_data(investigation)
    @hazard.assign_attributes(session[:hazard] || {})
    @hazard.assign_attributes(hazard_params || {})
    session[:hazard] = @hazard.attributes
  end

  def hazard_params
    return {} if params[:hazard].blank?

    handle_type_params
    params.require(:hazard).permit(
      :hazard_type, :description, :affected_parties, :risk_level,
    )
  end

  def handle_type_params
    if params[:hazard][:set_risk_level] == "none"
      params[:hazard][:risk_level] = params[:hazard][:set_risk_level]
    end
  end

  def clear_session
    session[:hazard] = nil
  end

  def get_file_params_key
    :hazard
  end

  def success_notice; end
  def create_hazard_audit_activity; end
end
