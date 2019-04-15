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
      :overview,
      :details,
      :has_consumer_info
    )
  end

  def set_attachments
    @transcript_blob, @related_attachment_blob = load_file_attachments
  end

  def update_attachments
    update_blob_metadata @transcript_blob, transcript_metadata
    update_blob_metadata @related_attachment_blob, related_attachment_metadata
  end

  def correspondence_valid?
    @correspondence.validate(step || steps.last)
    @correspondence.validate_transcript_and_content(@transcript_blob) if step == :content
    validate_blob_size(@transcript_blob, @correspondence.errors, "transcript")
    validate_blob_size(@related_attachment_blob, @correspondence.errors, "related attachment")
    @correspondence.errors.empty?
  end

  def attach_files
    attach_blob_to_attachment_slot(@transcript_blob, @correspondence.transcript)
    attach_blob_to_attachment_slot(@related_attachment_blob, @correspondence.related_attachment)
    attach_blobs_to_list(@transcript_blob, @related_attachment_blob, @investigation.documents)
  end

  def save_attachments
    @transcript_blob.save if @transcript_blob
    @related_attachment_blob.save if @related_attachment_blob
  end
end
