class InvestigationsController < ApplicationController
  before_action :set_investigation, only: [:show, :edit, :update, :destroy]

  # GET /investigations
  # GET /investigations.json
  def index
    @investigations = Investigation.all
  end

  # GET /investigations/1
  # GET /investigations/1.json
  def show
  end

  # GET /investigations/new
  def new
    @investigation = Investigation.new
  end

  # GET /investigations/1/edit
  def edit
  end

  # POST /investigations
  # POST /investigations.json
  def create
    @investigation = Investigation.new(investigation_params)

    respond_to do |format|
      if @investigation.save
        format.html { redirect_to @investigation, notice: 'Investigation was successfully created.' }
        format.json { render :show, status: :created, location: @investigation }
      else
        format.html { render :new }
        format.json { render json: @investigation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /investigations/1
  # PATCH/PUT /investigations/1.json
  def update
    respond_to do |format|
      if @investigation.update(investigation_params)
        format.html { redirect_to @investigation, notice: 'Investigation was successfully updated.' }
        format.json { render :show, status: :ok, location: @investigation }
      else
        format.html { render :edit }
        format.json { render json: @investigation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /investigations/1
  # DELETE /investigations/1.json
  def destroy
    @investigation.destroy
    respond_to do |format|
      format.html { redirect_to investigations_url, notice: 'Investigation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_investigation
      @investigation = Investigation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def investigation_params
      params.require(:investigation).permit(:description, :is_closed, :source, :severity, :product_id)
    end
end
