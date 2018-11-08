class Investigations::Hazards::FlowController < ApplicationController
  include FileConcern
  include Wicked::Wizard
  steps :details, :summary
  before_action :load_relevant_objects, only: %i[show update create]

  def new
    clear_session
    initialize_file_attachment
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  def create

  end

  def show
    render_wizard
  end

  def update
    if @hazard.invalid?
      render step
    else
      redirect_to next_wizard_path
    end
  end

  private

  def load_relevant_objects

  end

  def set_hazard_data(investigation)

  end

  def hazard_params
    return {} if params[:hazard].blank?

    handle_type_params
    params.require(:hazard).permit(
      :hazard_type, :description, :affected_parties, :risk_level,
    )
  end

  def handle_type_params
    if params[:hazard][:set_risk_level] == "none"
      params[:hazard][:risk_level] = params[:hazard][:set_risk_level]
    end
  end

  def clear_session
    session[:hazard] = nil
  end

  def get_file_params_key
    :hazard
  end
end
