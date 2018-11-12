class Investigations::EmailsController < ApplicationController
  include FileConcern
  include Wicked::Wizard
  steps :context, :content, :confirmation
  before_action :load_relevant_objects, only: %i[show update create]

  def new
    clear_session
    initialize_file_attachment :email_file
    initialize_file_attachment :email_attachment
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  def create
    attach_file_to_list(@email_file, :email_file, @correspondence.documents)
    attach_file_to_list(@email_attachment, :email_attachment, @correspondence.documents)
    @investigation.correspondences << @correspondence
    @investigation.save
    redirect_to investigation_path(@investigation)
  end

  def show
    render_wizard
  end

  def update
    @correspondence.validate(step)
    validate_blob_size(@email_file, @correspondence.errors, :email_file)
    validate_blob_size(@email_attachment, @correspondence.errors, :email_attachment)
    if @correspondence.errors.any?
      render step
    else
      redirect_to next_wizard_path
    end
  end

private

  def load_relevant_objects
    @investigation = Investigation.find(params[:investigation_id])
    @email_file = load_file_attachment :email_file
    @email_attachment = load_file_attachment :email_attachment
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
        :overview, :details
    )
  end

  def clear_session
    session[:correspondence] = nil
  end

  def get_file_params_key
    :correspondence
  end

  def get_file_session_key
    :email_file_id
  end

  def suggested_values
    {
        day: Time.zone.today.day,
        month: Time.zone.today.month,
        year: Time.zone.today.year
    }
  end
end
