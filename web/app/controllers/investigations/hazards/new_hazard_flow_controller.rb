class Investigations::Hazards::NewHazardFlowController < Investigations::Hazards::FlowController
private

  def preload_hazard(investigation)
    @hazard = Hazard.new
    @hazard.investigation = investigation
  end

  def success_notice
    'Hazard details were saved.'
  end

  def update_investigation_hazard
    @investigation.hazard = @hazard
  end
end
