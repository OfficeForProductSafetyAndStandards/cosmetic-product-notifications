class Investigations::EmailsController < ApplicationController
  include FileConcern
  set_attachment_names :email_file, :email_attachment
  set_file_params_key :correspondence_email

  include Wicked::Wizard
  steps :context, :content, :confirmation

  before_action :set_investigation
  before_action :set_correspondence, only: %i[show update create]
  before_action :set_attachments, only: %i[show update create]
  before_action :store_correspondence, only: %i[update]

  def new
    clear_session
    initialize_file_attachments
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  def create
    update_attachments
    if correspondence_valid? && @investigation.save
      attach_files
      save_attachments
      AuditActivity::Correspondence::AddEmail.from(@correspondence, @investigation)
      redirect_to investigation_path @investigation, notice: 'Correspondence was successfully recorded'
    else
      redirect_to investigation_path(@investigation), notice: "Correspondence could not be saved."
    end
  end

  def show
    render_wizard
  end

  def update
    update_attachments
    if correspondence_valid?
      save_attachments
      redirect_to next_wizard_path
    else
      render step
    end
  end

private

  def clear_session
    session[correspondence_params_key] = nil
  end

  def set_investigation
    @investigation = Investigation.find(params[:investigation_id])
  end

  def set_correspondence
    @correspondence = Correspondence::Email.new correspondence_params
    @investigation.association(:correspondences).add_to_target(@correspondence)
  end

  def store_correspondence
    session[correspondence_params_key] = @correspondence.attributes if @correspondence.valid?(step)
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

  def correspondence_params
    session_params.merge(request_params)
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
        :attachment_description
    )
  end

  def session_params
    session[correspondence_params_key] || {}
  end

  def email_file_metadata
    get_attachment_metadata_params(:email_file).merge(
        title: correspondence_params["overview"],
        description: "Original email as a file"
    )
  end

  def email_attachment_metadata
    get_attachment_metadata_params(:email_attachment).merge(
        title: correspondence_params["overview"]
    )
  end

  def correspondence_params_key
    "correspondence_email"
  end
end
