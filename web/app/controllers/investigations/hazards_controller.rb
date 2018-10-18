class Investigations::HazardsController < ApplicationController
  include Wicked::Wizard
  steps :details, :summary

  # GET /hazards/1
  # GET /hazards/1.json
  def show
    @hazard = Hazard.new(session[:hazard])
    render_wizard
  end

  # GET /hazards/new
  def new
    save_investigation
    load_hazard
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  # POST /hazards
  # POST /hazards.json
  def create
    @investigation = Investigation.find_by(id: session[:invesigation_id])
    @hazard = Hazard.new(hazard_params)
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

  # DELETE /hazards/1
  # DELETE /hazards/1.json
  def destroy
    @hazard.destroy
    respond_to do |format|
      format.html {redirect_to hazards_url, notice: 'Hazard was successfully destroyed.'}
      format.json {head :no_content}
    end
  end

  private

  def load_hazard
    session[:hazard] = {}
    @investigation = Investigation.find_by(id: session[:invesigation_id])

    hazard_data = {}
    hazard_data = hazard_data.merge(params[:hazard]) if (params[:hazard])
    hazard_data = hazard_data.merge(@investigation.hazard.attributes) if (@investigation.hazard)
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
