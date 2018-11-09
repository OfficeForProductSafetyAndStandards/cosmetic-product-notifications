class Investigations::EmailsController < ApplicationController
  include Wicked::Wizard
  steps :context, :content, :confirmation
  before_action :load_relevent_objects, only: %i[show]

  def new
    clear_session
    redirect_to wizard_path(steps.first)
  end

  def show
    render_wizard
  end

private

  def load_relevent_objects
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

    handle_type_params
    params.require(:correspondence).permit(
        :correspondent_name, :correspondent_type, :contact_method, :phone_number, :email_address, :day, :month, :year,
        :overview, :details
    )
  end

  def clear_session
    session[:correspondence] = nil
  end

  def suggested_values
    values = {
        day: Time.zone.today.day,
        month: Time.zone.today.month,
        year: Time.zone.today.year
    }

    reporter = @investigation.reporter
    if reporter
      values = values.merge(
          correspondent_name: reporter.name,
          contact_method: :email,
          phone_number: reporter.phone_number,
          email_address: reporter.email_address
      )
    end

    values
  end
end
