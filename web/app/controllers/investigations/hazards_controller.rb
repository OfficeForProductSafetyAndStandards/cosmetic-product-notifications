class Investigations::HazardsController < ApplicationController
  include Wicked::Wizard
  steps :details, :summary

  # GET /hazards
  # GET /hazards.json
  def index
    @hazards = Hazard.all
  end

  # GET /hazards/1
  # GET /hazards/1.json
  def show
    session[:hazard] = {} if step == steps.first
    @hazard = Hazard.new(session[:hazard])
    render_wizard
  end

  # GET /hazards/new
  def new
    save_investigation
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  # GET /hazards/1/edit
  def edit
  end
  def index
  end

  # POST /hazards
  # POST /hazards.json
  def create
    @investigation = Investigation.find_by(id: session[:invesigation_id])
    @hazard = Hazard.new(hazard_params)
    @investigation.hazard = @hazard
    respond_to do |format|
      if @investigation.save
        format.html { redirect_to @hazard, notice: 'Hazard was successfully created.' }
        format.json { render :show, status: :created, location: @hazard }
      else
        format.html { render :new }
        format.json { render json: @hazard.errors, status: :unprocessable_entity }
      end
    end
    session[:hazard] = {}
  end

  # PATCH/PUT /hazards/1
  # PATCH/PUT /hazards/1.json
  def update
    update_partial_hazard
    @investigation = Investigation.find_by(id: session[:invesigation_id])
    p @investigation
    p "==========="
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
      format.html { redirect_to hazards_url, notice: 'Hazard was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_hazard
    #   @hazard = Hazard.find(params[:id])
    # end

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
