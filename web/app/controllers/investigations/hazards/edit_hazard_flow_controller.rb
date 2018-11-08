class Investigations::Hazards::EditHazardFlowController < Investigations::Hazards::FlowController

  private
  def load_relevant_objects
    super.load_relevant_objects
    if @file.blank? && @hazard.risk_assessment.attached?
      @file = @hazard.risk_assessment.blob
    end
  end

  def set_hazard_data(investigation)
    super.set_hazard_data
    session[:hazard] = @hazard.attributes
  end

  def create_hazard_audit_activity
    AuditActivity::Hazard::Update.from(@hazard, @investigation)
  end

  def success_notice
    'Hazard details were updated.'
  end
end
