class Investigations::PhoneCallsController < Investigations::CorrespondenceController
  set_attachment_names :transcript
  set_file_params_key :correspondence_phone_call

private

  def audit_class
    AuditActivity::Correspondence::AddPhoneCall
  end

  def model_class
    Correspondence::PhoneCall
  end

  def file_metadata
    get_attachment_metadata_params(:transcript).merge(
      title: correspondence_params["overview"],
      description: "Call transcript",
      has_consumer_info: correspondence_params["has_consumer_info"]
    )
  end

  def request_params
    return {} if params[correspondence_params_key].blank?

    params.require(correspondence_params_key).permit(
      :correspondent_name,
      :phone_number,
      :overview,
      :details,
      :has_consumer_info
    )
  end

  def set_attachments
    transcript_blob, * = load_file_attachments
    @transcript_document_model = Document.new(transcript_blob)
  end

  def update_attachments
    @transcript_document_model.update_file file_metadata
  end

  def correspondence_valid?
    @correspondence.validate(step || steps.last)
    @transcript_document_model.validate
    @correspondence.validate_transcript_and_content(@transcript_document_model.file) if step == :content
    @correspondence.errors.empty? && @transcript_document_model.errors.empty?
  end

  def attach_files
    @transcript_document_model.attach_blob_to_attachment_slot(@correspondence.transcript)
    @transcript_document_model.attach_blob_to_list(@investigation.documents)
  end
end
