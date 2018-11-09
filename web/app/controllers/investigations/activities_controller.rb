class Investigations::ActivitiesController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  before_action :set_investigation, only: %i[create]
  before_action :create_activity, only: %i[create]

  # POST /activities
  # POST /activities.json
  def create
    respond_to do |format|
      if @activity.save
        format.html do
          redirect_to investigation_url(@investigation), notice: "Comment was successfully added."
        end
        format.json { render :show, status: :created, location: @activity }
      else
        format.html do
          redirect_to investigation_url(@investigation), notice: "Comment was not successfully added."
        end
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

private

  def create_activity
    @activity = CommentActivity.new(activity_params)
    @investigation.activities << @activity
    @activity.source = UserSource.new(user: current_user)
  end

  def set_investigation
    @investigation = Investigation.find(params[:investigation_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def activity_params
    params.require(:comment_activity).permit(:body)
  end
end
