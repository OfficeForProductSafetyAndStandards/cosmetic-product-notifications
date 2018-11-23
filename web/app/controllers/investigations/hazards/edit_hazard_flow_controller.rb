class Investigations::Hazards::EditHazardFlowController < Investigations::Hazards::FlowController
  include FileConcern
  set_attachment_names :file
  set_file_params_key :hazard

private

  def preload_hazard(investigation)
    @hazard = investigation.hazard
    @hazard = Hazard.new if @hazard.blank?
    session[:hazard] = (@hazard&.attributes || {}).merge(session[:hazard] || {})
  end

  def success_notice
    'Hazard details were updated.'
  end

  def update_investigation_hazard
    @investigation.hazard.update(@hazard.attributes.tap { |h| h.delete('id') })
  end
end
