class Investigations::Hazards::FlowController < ApplicationController
  include FileConcern
  include HazardsHelper
  include Wicked::Wizard
  steps :details, :summary
  before_action :load_relevant_objects, only: %i[show update create]

  def new
    clear_session
    initialize_file_attachment
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  def create
    update_risk_assessment
    update_investigation_hazard
    @investigation.save
    redirect_to @investigation, notice: success_notice
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

  def set_hazard_data(investigation)
    preload_hazard(investigation)
    @hazard.assign_attributes(session[:hazard] || {})
    @hazard.assign_attributes(hazard_params || {})
    session[:hazard] = @hazard.attributes
    if @hazard.risk_level.present?
      @hazard.set_risk_level = @hazard.risk_level == "none" ? "none" : "yes"
    end
  end

  def clear_session
    session[:hazard] = nil
  end

  def success_notice; end

  def perform_additional_loads; end

  def preload_hazard(investigation); end

  def update_investigation_hazard; end
end
