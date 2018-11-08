class Investigations::Hazards::NewHazardFlowController < Investigations::Hazards::FlowController

  def create
    attach_file_to_attachment_slot(@file, @hazard.risk_assessment)
    @investigation.hazard = @hazard
    @investigation.save
    activity = AuditActivity::Hazard::Add.from(@hazard, @investigation)
    attach_file_to_attachment_slot(@file, activity.risk_assessment)
    redirect_to @investigation, notice: 'Hazard details were saved.'
  end

  private

  def load_relevant_objects
    @investigation = Investigation.find_by(id: params[:investigation_id])
    @file = load_file_attachment
    set_hazard_data(@investigation)
  end

  def set_hazard_data(investigation)
    @hazard = Hazard.new
    @hazard.investigation = investigation
    @hazard.assign_attributes(session[:hazard] || {})
    @hazard.assign_attributes(hazard_params || {})
    session[:hazard] = @hazard.attributes
  end

end
