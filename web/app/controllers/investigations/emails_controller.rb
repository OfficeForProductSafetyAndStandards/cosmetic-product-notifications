class Investigations::EmailsController < ApplicationController
  include FileConcern
  set_attachment_categories :email_file, :email_attachment
  set_file_params_key :correspondence

  include Wicked::Wizard
  steps :context, :content, :confirmation
  before_action :load_relevant_objects, only: %i[show update create]

  def new
    clear_session
    initialize_file_attachments
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  def create
    attach_files
    @investigation.correspondences << @correspondence
    if @investigation.save
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
    @correspondence.validate(step)
    validate_blob_sizes(@correspondence.errors, email_file: @email_file, email_attachment: @email_attachment)
    if @correspondence.errors.any?
      render step
    else
      redirect_to next_wizard_path
    end
  end

private

  def attach_files
    attach_files_to_list(@correspondence.documents, email_file: @email_file, email_attachment: @email_attachment)
    attach_files_to_list(@investigation.documents, email_file: @email_file, email_attachment: @email_attachment)
  end

  def load_relevant_objects
    @investigation = Investigation.find(params[:investigation_id])
    @email_file, @email_attachment = load_file_attachments
    if step == :content
      add_metadata(@email_file, email_file_metadata)
      add_metadata(@email_attachment, email_attachment_metadata)
    end
    load_correspondence
  end

  def load_correspondence
    data_from_previous_steps = session[:correspondence] || suggested_values
    session[:correspondence] = data_from_previous_steps.merge(correspondence_params || {})
    @correspondence = Correspondence.new(session[:correspondence])
  end

  def correspondence_params
    return {} if params[:correspondence].blank?

    params.require(:correspondence).permit(
      :correspondent_name, :correspondent_type, :contact_method, :phone_number, :email_address, :day, :month, :year,
      :overview, :details, :email_direction, :email_subject
    )
  end

  def clear_session
    session[:correspondence] = nil
  end

  def suggested_values
    {
        day: Time.zone.today.day,
        month: Time.zone.today.month,
        year: Time.zone.today.year
    }
  end

  def email_file_metadata
    {
      title: correspondence_params[:overview],
      description: "Original email as a file"
    }
  end

  def email_attachment_metadata
    {
      title: correspondence_params[:overview],
      description: correspondence_params[:attachment_description]
    }
  end
end
