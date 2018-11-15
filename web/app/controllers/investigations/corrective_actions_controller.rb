class CorrectiveActionsController < ApplicationController
  before_action :set_corrective_action, only: [:show, :edit, :update, :destroy]

  # GET /corrective_actions
  # GET /corrective_actions.json
  def index
    @corrective_actions = CorrectiveAction.all
  end

  # GET /corrective_actions/1
  # GET /corrective_actions/1.json
  def show
  end

  # GET /corrective_actions/new
  def new
    @corrective_action = CorrectiveAction.new
  end

  # GET /corrective_actions/1/edit
  def edit
  end

  # POST /corrective_actions
  # POST /corrective_actions.json
  def create
    @corrective_action = CorrectiveAction.new(corrective_action_params)

    respond_to do |format|
      if @corrective_action.save
        format.html { redirect_to @corrective_action, notice: 'Corrective action was successfully created.' }
        format.json { render :show, status: :created, location: @corrective_action }
      else
        format.html { render :new }
        format.json { render json: @corrective_action.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /corrective_actions/1
  # PATCH/PUT /corrective_actions/1.json
  def update
    respond_to do |format|
      if @corrective_action.update(corrective_action_params)
        format.html { redirect_to @corrective_action, notice: 'Corrective action was successfully updated.' }
        format.json { render :show, status: :ok, location: @corrective_action }
      else
        format.html { render :edit }
        format.json { render json: @corrective_action.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /corrective_actions/1
  # DELETE /corrective_actions/1.json
  def destroy
    @corrective_action.destroy
    respond_to do |format|
      format.html { redirect_to corrective_actions_url, notice: 'Corrective action was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_corrective_action
      @corrective_action = CorrectiveAction.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def corrective_action_params
      params.require(:corrective_action).permit(:date_decided, :details, :legislation, :summary, :investigation_id, :product_id, :business_id)
    end
end
