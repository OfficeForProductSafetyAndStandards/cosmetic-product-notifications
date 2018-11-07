class Investigations::HazardsController < ApplicationController
  include FileConcern
  include Wicked::Wizard
  steps :details, :summary
  before_action :load_relevant_objects, only: %i[show update create risk_level update_risk_level]

  def new
    clear_session
    initialize_file_attachment
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  def create
    attach_file_to_attachment_slot(@file, @hazard.risk_assessment)
    @investigation.hazard = @hazard
    @investigation.save
    activity = AuditActivity::Hazard::Add.from(@hazard, @investigation)
    attach_file_to_attachment_slot(@file, activity.risk_assessment)
    redirect_to @investigation, notice: 'Hazard details were updated.'
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

  def risk_level; end

  def update_risk_level
    @hazard.save
    redirect_to @investigation, notice: 'Risk was successfully updated.'
  end

private

  def load_relevant_objects
    @investigation = Investigation.find_by(id: params[:investigation_id])
    @file = load_file_attachment
    set_hazard_data
    if @file.blank? && @hazard.risk_assessment.attached?
      @file = @hazard.risk_assessment.blob
    end
  end


  def set_hazard_data
    if @investigation.hazard
      @hazard = @investigation.hazard
    else
      @hazard = Hazard.new
      @hazard.investigation = @investigation
    end
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
end
