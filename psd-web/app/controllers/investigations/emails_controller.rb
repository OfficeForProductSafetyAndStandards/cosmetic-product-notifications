class Investigations::EmailsController < Investigations::CorrespondenceController
  set_file_params_key :correspondence_email
  set_attachment_names :email_file, :email_attachment

private

  def audit_class
    AuditActivity::Correspondence::AddEmail
  end

  def model_class
    Correspondence::Email
  end

  def common_file_metadata
    {
        title: correspondence_params["overview"],
        has_consumer_info: correspondence_params["has_consumer_info"]
    }
  end

  def email_file_metadata
    get_attachment_metadata_params(:email_file)
        .merge(common_file_metadata)
        .merge(
          description: "Original email as a file"
        )
  end

  def email_attachment_metadata
    get_attachment_metadata_params(:email_attachment)
        .merge(common_file_metadata)
  end

  def request_params
    return {} if params[correspondence_params_key].blank?

    params.require(correspondence_params_key).permit(
      :correspondent_name,
      :email_address,
      :email_direction,
      :overview,
      :details,
      :email_subject,
      :attachment_description,
      :has_consumer_info
    )
  end

  def set_attachments
    @email_file_blob, @email_attachment_blob = load_file_attachments
  end

  def update_attachments
    update_blob_metadata @email_file_blob, email_file_metadata
    update_blob_metadata @email_attachment_blob, email_attachment_metadata
  end

  def correspondence_valid?
    @correspondence.validate(step || steps.last)
    @correspondence.validate_email_file_and_content(@email_file_blob) if step == :content
    validate_blob_size(@email_file_blob, @correspondence.errors, "email file")
    validate_blob_size(@email_attachment_blob, @correspondence.errors, "email attachment")
    @correspondence.errors.empty?
  end

  def attach_files
    attach_blob_to_attachment_slot(@email_file_blob, @correspondence.email_file)
    attach_blob_to_attachment_slot(@email_attachment_blob, @correspondence.email_attachment)
    attach_blobs_to_list(@email_file_blob, @email_attachment_blob, @investigation.documents)
  end

  def save_attachments
    @email_file_blob.save if @email_file_blob
    @email_attachment_blob.save if @email_attachment_blob
  end
end
