module HazardsHelper
  def update_risk_assessment
    attach_blob_to_attachment_slot(@file, @hazard.risk_assessment)
  end

  def load_relevant_objects
    @investigation = Investigation.find_by(id: params[:investigation_id])
    @file, * = load_file_attachments
    set_hazard_data(@investigation)

    if @file.blank? && @hazard.risk_assessment.attached?
      @file = @hazard.risk_assessment.blob
    end
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
end
