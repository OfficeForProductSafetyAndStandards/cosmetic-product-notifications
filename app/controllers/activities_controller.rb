class ActivitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_activity, only: %i[show edit update destroy]
  before_action :create_activity, only: %i[create]

  # GET /activities
  # GET /activities.json
  def index
    @investigation = Investigation.find(params[:investigation_id])
    @activities = @investigation.activities.paginate(page: params[:page], per_page: 20)
  end

  # GET /activities/1
  # GET /activities/1.json
  def show; end

  # GET /activities/new
  def new
    investigation = Investigation.find(params[:investigation_id])
    @activity = investigation.activities.build
  end

  # GET /activities/1/edit
  def edit; end

  # POST /activities
  # POST /activities.json
  def create
    respond_to do |format|
      if @activity.save
        format.html { redirect_to @activity, notice: "Activity was successfully created." }
        format.json { render :show, status: :created, location: @activity }
      else
        format.html { render :new }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /activities/1
  # PATCH/PUT /activities/1.json
  def update
    authorize @activity
    respond_to do |format|
      if @activity.update(activity_params)
        format.html { redirect_to @activity, notice: "Activity was successfully updated." }
        format.json { render :show, status: :ok, location: @activity }
      else
        format.html { render :edit }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /activities/1
  # DELETE /activities/1.json
  def destroy
    authorize @activity
    @activity.destroy
    respond_to do |format|
      format.html do
        redirect_to investigation_activities_url(@activity.investigation),
                    notice: "Activity was successfully destroyed."
      end
      format.json { head :no_content }
    end
  end

  private

  def create_activity
    investigation = Investigation.find(params[:investigation_id])
    @activity = investigation.activities.create(activity_params)
    @activity.source = UserSource.new(user: current_user)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_activity
    @activity = Activity.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def activity_params
    params.require(:activity).permit(:investigation_id, :activity_type_id, :notes)
  end
end
