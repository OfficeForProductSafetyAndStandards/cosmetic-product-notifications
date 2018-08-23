class ActivitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_investigation, only: %i[index new create]
  before_action :create_activity, only: %i[create]

  # GET /activities
  # GET /activities.json
  def index
    @activities = @investigation.activities.paginate(page: params[:page], per_page: 20)
  end

  # GET /activities/new
  def new
    @activity = @investigation.activities.build
  end

  # POST /activities
  # POST /activities.json
  def create
    respond_to do |format|
      if @activity.save
        format.html do
          redirect_to investigation_activities_path(@investigation),
                      notice: "Activity was successfully created."
        end
        format.json { render :show, status: :created, location: @activity }
      else
        format.html { render :new }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def create_activity
    @activity = @investigation.activities.create(activity_params)
    @activity.source = UserSource.new(user: current_user)
  end

  def set_investigation
    @investigation = Investigation.find(params[:investigation_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def activity_params
    params.require(:activity).permit(:investigation_id, :activity_type, :notes)
  end
end
