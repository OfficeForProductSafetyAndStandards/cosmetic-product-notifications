class Investigations::HazardsController < ApplicationController
  include Wicked::Wizard
  steps :details, :summary

  before_action :set_investigation, only: %i[show update create risk_level update_risk_level]
  before_action :set_hazard_data, only: %i[show update create risk_level update_risk_level]

  # GET /investigations/1/hazards/new
  def new
    session[:hazard] = nil
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  # GET /investigations/1/hazards/step
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

  # POST /hazards
  # POST /hazards.json
  def create
    @hazard.save
    redirect_to @investigation, notice: 'Hazard details were updated.'
  end

  def risk_level; end

  def update_risk_level
    @hazard.save
    redirect_to @investigation, notice: 'Risk was successfully updated.'
  end

private

  def set_investigation
    @investigation = Investigation.find_by(id: params[:investigation_id])
  end

  def set_hazard_data
    if @investigation.hazard
      @hazard = @investigation.hazard
    else
      @hazard = Hazard.new
      @hazard.investigation = @investigation
    end

    @hazard.assign_attributes(session[:hazard] || {})
    @hazard.assign_attributes(hazard_params || {})

    session[:hazard] = @hazard.attributes
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def hazard_params
    return {} if params[:hazard].blank?

    params.require(:hazard).permit(
      :hazard_type, :description, :affected_parties, :risk_level
    )
  end
end
