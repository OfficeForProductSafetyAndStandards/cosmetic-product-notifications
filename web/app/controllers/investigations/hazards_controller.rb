class Investigations::HazardsController < ApplicationController
  include Wicked::Wizard
  steps :details, :summary

  # GET /hazards/new
  def new
    save_investigation
    load_hazard
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  # GET /hazards/1
  # GET /hazards/1.json
  def show
    @hazard = Hazard.new(session[:hazard])
    render_wizard
  end

  # POST /hazards
  # POST /hazards.json
  def create
    @hazard = Hazard.new(hazard_params)
    @investigation = Investigation.find_by(id: session[:invesigation_id])
    @investigation.hazard = @hazard
    @investigation.save
    session[:hazard] = {}
    redirect_to @investigation, notice: 'Hazard was successfully created.'
  end

  # PATCH/PUT /hazards/1
  # PATCH/PUT /hazards/1.json
  def update
    update_partial_hazard
    @investigation = Investigation.find_by(id: session[:invesigation_id])
    @investigation.hazard = @hazard
    if !@hazard.valid?
      render step
    else
      redirect_to next_wizard_path
    end
  end

  def risk_level
    save_investigation
    load_hazard
    @hazard = Hazard.new(session[:hazard])
  end

  def update_risk_level
    load_hazard
    @investigation.hazard = Hazard.new(session[:hazard])
    @investigation.save
    redirect_to @investigation, notice: 'Hazard was successfully updated.'
    session[:hazard] = {}
    session[:invesigation_id] = {}
  end

  private

  def load_hazard
    session[:hazard] = {}
    @investigation = Investigation.find_by(id: session[:invesigation_id])
    hazard_data = {}
    hazard_data = hazard_data.merge(@investigation.hazard.attributes) if (@investigation.hazard)
    hazard_data = hazard_data.merge(params[:hazard].permit!) if (params[:hazard])
    if (hazard_data!= {})
      params[:hazard] = hazard_data
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

  def update_partial_hazard
    session[:hazard] = (session[:hazard] || {}).merge(hazard_params)
    @hazard = Hazard.new(session[:hazard])
    session[:hazard] = @hazard.attributes
  end
end
