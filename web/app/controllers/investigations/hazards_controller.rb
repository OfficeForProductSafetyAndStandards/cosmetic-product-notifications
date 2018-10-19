class Investigations::HazardsController < ApplicationController
  include Wicked::Wizard
  steps :details, :summary

  # GET /hazards/new
  def new
    save_investigation
    load_hazard_and_investigation
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  def edit
    save_investigation
    load_hazard_and_investigation
    redirect_to previous_wizard_path
  end

  # GET /hazards/1
  # GET /hazards/1.json
  def show
    load_hazard_and_investigation
    render_wizard
  end

  # POST /hazards
  # POST /hazards.json
  def create
    load_hazard_and_investigation
    @investigation.hazard = @hazard
    @investigation.save
    session[:hazard] = {}
    redirect_to @investigation, notice: 'Hazard was successfully created.'
  end

  # PATCH/PUT /hazards/1
  # PATCH/PUT /hazards/1.json
  def update
    load_hazard_and_investigation
    @investigation.hazard = @hazard
    if !@hazard.valid?
      render step
    else
      redirect_to next_wizard_path
    end
  end

  def risk_level
    save_investigation
    load_hazard_and_investigation
  end

  def update_risk_level
    load_hazard_and_investigation
    @investigation.hazard = @hazard
    @investigation.save
    redirect_to @investigation, notice: 'Risk was successfully updated.'
  end

private

  def load_hazard_and_investigation
    @investigation = Investigation.find_by(id: session[:invesigation_id])
    load_hazard_data
    @hazard = Hazard.new(session[:hazard])
  end

  def load_hazard_data
    hazard_data_from_database = {} || @investigation.hazard.attributes
    hazard_data_from_previous_steps = hazard_data_from_database.merge(session[:hazard] || {})
    hazard_data_after_last_step = hazard_data_from_previous_steps.merge(params[:hazard]&.permit! || {})
    if hazard_data_after_last_step != {}
      params[:hazard] = hazard_data_after_last_step
      session[:hazard] = hazard_params
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def hazard_params
    if !params[:hazard]
      session[:hazard]
    else
      params.require(:hazard).permit(:hazard_type, :description, :affected_parties, :risk_level, :investigation)
    end
  end

  def save_investigation
    session[:invesigation_id] = params[:investigation_id]
  end
end
