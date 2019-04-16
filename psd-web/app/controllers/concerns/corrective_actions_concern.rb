module CorrectiveActionsConcern
  extend ActiveSupport::Concern

  def set_investigation
    @investigation = Investigation.find_by!(pretty_id: params[:investigation_pretty_id])
    authorize @investigation, :show?
  end

  def set_corrective_action
    @corrective_action = @investigation.corrective_actions.build(corrective_action_params)
  end

  def corrective_action_params
    corrective_action_session_params.merge(corrective_action_request_params)
  end

  def set_attachment
    file_blob, * = load_file_attachments
    @file_model = Document.new(file_blob)
    if file_blob && @corrective_action.related_file == "Yes"
      @file_model.attach_blob_to_list(@corrective_action.documents)
    elsif file_blob
      file_blob.purge
    end
  end

  def corrective_action_valid?
    @corrective_action.validate(step)
    @file_model.validate
    @corrective_action.errors.empty? && @file_model.errors.empty?
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
                                              :year,
                                              :related_file)
  end

  def corrective_action_file_metadata
    get_attachment_metadata_params(:file).merge(
      title: @corrective_action.summary,
      other_type: "Corrective action document",
      document_type: :other
    )
  end
end
