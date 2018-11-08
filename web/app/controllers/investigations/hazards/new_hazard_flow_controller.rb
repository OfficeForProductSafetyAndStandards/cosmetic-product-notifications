class Investigations::Hazards::NewHazardFlowController < Investigations::Hazards::FlowController

  private
  def set_hazard_data(investigation)
    @hazard = Hazard.new
    @hazard.investigation = investigation
    super.set_hazard_data
  end

  def create_hazard_audit_activity
    AuditActivity::Hazard::Add.from(@hazard, @investigation)
  end

  def success_notice
    'Hazard details were saved.'
  end
end
