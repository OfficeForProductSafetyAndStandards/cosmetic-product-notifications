class Investigations::EmailsController < ApplicationController
  include Wicked::Wizard
  steps :context, :content, :confirmation
  before_action :load_relevant_objects, only: %i[show update create]

  def new
    clear_session
    redirect_to wizard_path(steps.first)
  end

  def create
    @investigation.correspondences << @correspondence
    @investigation.save
    redirect_to investigation_path(@investigation)
  end

  def show
    render_wizard
  end

  def update
    @correspondence.validate(step)
    # validate_blob_size(@file, @correspondence.errors)
    if @correspondence.errors.any?
      render step
    else
      redirect_to next_wizard_path
    end
  end

private

  def load_relevant_objects
    @investigation = Investigation.find(params[:investigation_id])
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

  def suggested_values
    {
        day: Time.zone.today.day,
        month: Time.zone.today.month,
        year: Time.zone.today.year
    }
  end
end
