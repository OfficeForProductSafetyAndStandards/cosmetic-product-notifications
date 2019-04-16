class Investigations::MeetingsController < Investigations::CorrespondenceController
  set_attachment_names :transcript, :related_attachment
  set_file_params_key :correspondence_meeting

private

  def audit_class
    AuditActivity::Correspondence::AddMeeting
  end

  def model_class
    Correspondence::Meeting
  end

  def transcript_metadata
    get_attachment_metadata_params(:transcript).merge(
      title: correspondence_params["overview"],
      description: "Meeting transcript"
    )
  end

  def related_attachment_metadata
    get_attachment_metadata_params(:related_attachment).merge(
      title: correspondence_params["overview"]
    )
  end

  def request_params
    return {} if params[correspondence_params_key].blank?

    params.require(correspondence_params_key).permit(
      :correspondent_name,
      :day,
      :month,
      :year,
      :overview,
      :details,
      :has_consumer_info
    )
  end

  def set_attachments
    transcript_blob, related_attachment_blob = load_file_attachments
    @transcript_file_model = Document.new(transcript_blob)
    @related_attachment_file_model = Document.new(related_attachment_blob)
  end

  def update_attachments
    @transcript_file_model.update_file transcript_metadata
    @related_attachment_file_model.update_file related_attachment_metadata
  end

  def correspondence_valid?
    @correspondence.validate(step || steps.last)
    @transcript_file_model.validate
    @related_attachment_file_model.validate
    @correspondence.validate_transcript_and_content(@transcript_file_model.get_blob) if step == :content
    @correspondence.errors.empty? && @transcript_file_model.errors.empty? && @related_attachment_file_model.errors.empty?
  end

  def attach_files
    @transcript_file_model.attach_blob_to_attachment_slot(@correspondence.transcript)
    @transcript_file_model.attach_blob_to_list(@investigation.documents)
    @related_attachment_file_model.attach_blob_to_attachment_slot(@correspondence.related_attachment)
    @related_attachment_file_model.attach_blob_to_list(@investigation.documents)
  end
end
