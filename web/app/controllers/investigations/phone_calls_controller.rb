class Investigations::PhoneCallsController < ApplicationController
  include FileConcern
  set_attachment_categories :file
  set_file_params_key :correspondence

  include Wicked::Wizard
  steps :context, :content, :confirmation
  before_action :load_relevant_objects, only: %i[show update create]

  def new
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  def create
    attach_files
    @investigation.correspondences << @correspondence
    if @investigation.save
      redirect_to investigation_path @investigation, notice: 'Correspondence was successfully recorded'
      AuditActivity::Correspondence::AddPhoneCall.from(@correspondence, @investigation)
    else
      redirect_to investigation_path @investigation, notice: "Correspondence could not be saved."
    end
  end

  def show
    render_wizard
  end

  def update
    @correspondence.validate(step)
    validate_blob_sizes @correspondence.errors, file: @file
    if @correspondence.errors.any?
      render step
    else
      redirect_to next_wizard_path
    end
  end

private

  def attach_files
    attach_files_to_list(@correspondence.documents, file: @file)
    attach_files_to_list(@investigation.documents, file: @file)
  end

  def load_relevant_objects
    @investigation = Investigation.find(params[:investigation_id])
    @file = load_file_attachment
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
        :correspondent_name, :phone_number, :day, :month, :year, :overview, :details
    )
  end

  def suggested_values
    {
        day: Time.zone.today.day,
        month: Time.zone.today.month,
        year: Time.zone.today.year
    }
  end
end
