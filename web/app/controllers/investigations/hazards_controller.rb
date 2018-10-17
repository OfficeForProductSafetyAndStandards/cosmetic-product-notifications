class Investigations::HazardsController < ApplicationController
  before_action :set_hazard, only: [:show, :edit, :update, :destroy]

  # GET /hazards
  # GET /hazards.json
  def index
    @hazards = Hazard.all
  end

  # GET /hazards/1
  # GET /hazards/1.json
  def show
  end

  # GET /hazards/new
  def new
    p params
    p "the right place ===  ===="
    session[:invesigation_id] = 1
    @hazard = Hazard.new
  end

  # GET /hazards/1/edit
  def edit
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
  end

  # PATCH/PUT /hazards/1
  # PATCH/PUT /hazards/1.json
  def update
    respond_to do |format|
      if @hazard.update(hazard_params)
        format.html { redirect_to @hazard, notice: 'Hazard was successfully updated.' }
        format.json { render :show, status: :ok, location: @hazard }
      else
        format.html { render :edit }
        format.json { render json: @hazard.errors, status: :unprocessable_entity }
      end
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
    def set_hazard
      @hazard = Hazard.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def hazard_params
      params.require(:hazard).permit(:hazard_type, :description, :affected_parties, :risk_level, :investigation)
    end
end
