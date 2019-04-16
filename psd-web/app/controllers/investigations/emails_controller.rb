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
      :day,
      :month,
      :year,
      :email_direction,
      :overview,
      :details,
      :email_subject,
      :attachment_description,
      :has_consumer_info
    )
  end

  def set_attachments
    email_file_blob, email_attachment_blob = load_file_attachments
    @email_file_model = Document.new(email_file_blob)
    @email_attachment_file_model = Document.new(email_attachment_blob)
  end

  def update_attachments
    @email_file_model.update_file email_file_metadata
    @email_attachment_file_model.update_file email_attachment_metadata
  end

  def correspondence_valid?
    @correspondence.validate(step || steps.last)
    @email_file_model.validate
    @email_attachment_file_model.validate
    @correspondence.validate_email_file_and_content(@email_file_model.get_blob) if step == :content
    @correspondence.errors.empty? && @email_file_model.errors.empty? && @email_attachment_file_model.errors.empty?
  end

  def attach_files
    @email_file_model.attach_blob_to_attachment_slot(@correspondence.email_file)
    @email_file_model.attach_blob_to_list(@investigation.documents)
    @email_attachment_file_model.attach_blob_to_attachment_slot(@correspondence.email_attachment)
    @email_attachment_file_model.attach_blob_to_list(@investigation.documents)
  end
end
