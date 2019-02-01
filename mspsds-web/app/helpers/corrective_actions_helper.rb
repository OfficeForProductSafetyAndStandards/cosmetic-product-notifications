module CorrectiveActionsHelper

  def set_investigation
    @investigation = Investigation.find(params[:investigation_id])
    authorize @investigation, :show?
  end

  def set_corrective_action
    @corrective_action = @investigation.corrective_actions.build(corrective_action_params)
  end

  def corrective_action_params
    corrective_action_session_params.merge(corrective_action_request_params)
  end

  def set_attachment
    @file_blob, * = load_file_attachments
  end

  def update_attachment
    update_blob_metadata @file_blob, corrective_action_file_metadata
  end

  def corrective_action_valid?
    @corrective_action.validate(step)
    validate_blob_size(@file_blob, @corrective_action.errors, "file")
    @corrective_action.errors.empty?
  end

  def corrective_action_request_params
    return {} if params[:corrective_action].blank?

    params.require(:corrective_action).permit(:product_id,
                                              :business_id,
                                              :legislation,
                                              :summary,
                                              :details,
                                              :day,
                                              :month,
                                              :year)
  end

  def corrective_action_file_metadata
    get_attachment_metadata_params(:file).merge(
        title: @corrective_action.summary,
        other_type: "Corrective action document",
        document_type: :other
    )
  end
end
