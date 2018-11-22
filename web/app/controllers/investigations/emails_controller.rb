class Investigations::EmailsController < ApplicationController
  include FileConcern
  set_attachment_names :email_file, :email_attachment
  set_file_params_key :correspondence

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
    if correspondence_valid? && @correspondence.save
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
    session[:correspondence] = nil
  end

  def set_investigation
    @investigation = Investigation.find(params[:investigation_id])
  end

  def set_correspondence
    @correspondence = @investigation.correspondences.build(correspondence_params)
  end

  def store_correspondence
    session[:correspondence] = @correspondence.attributes
  end

  def set_attachments
    @email_file, @email_attachment = load_file_attachments
  end

  def update_attachments
    update_blob_metadata @email_file, email_file_metadata
    update_blob_metadata @email_attachment, email_attachment_metadata
  end

  def correspondence_valid?
    @correspondence.validate(step || steps.last)
    validate_blob_size(@email_file, @correspondence.errors, "email file")
    validate_blob_size(@email_attachment, @correspondence.errors, "email attachment")
    @correspondence.errors.empty?
  end

  def attach_files
    attach_blob_to_attachment_slot(@email_file, @correspondence.email_file)
    attach_blob_to_attachment_slot(@email_attachment, @correspondence.email_attachment)
    attach_blobs_to_list(@email_file, @email_attachment, @investigation.documents)
  end

  def save_attachments
    @email_file.save if @email_file
    @email_attachment.save if @email_attachment
  end

  def correspondence_params
    session_params.merge(request_params)
  end

  def request_params
    return {} if params[:correspondence].blank?

    params.require(:correspondence).permit(
      :correspondent_name, :correspondent_type, :contact_method, :phone_number, :email_address, :day, :month, :year,
      :overview, :details, :email_direction, :email_subject, :attachment_description
    )
  end

  def session_params
    session[:correspondence] || suggested_values
  end

  def suggested_values
    {
        day: Time.zone.today.day,
        month: Time.zone.today.month,
        year: Time.zone.today.year
    }
  end

  def email_file_metadata
    get_attachment_metadata_params(:email_file).merge(
      title: correspondence_params[:overview],
      description: "Original email as a file"
    )
  end

  def email_attachment_metadata
    get_attachment_metadata_params(:email_attachment).merge(
      title: correspondence_params[:overview],
      description: correspondence_params[:attachment_description]
    )
  end
end
