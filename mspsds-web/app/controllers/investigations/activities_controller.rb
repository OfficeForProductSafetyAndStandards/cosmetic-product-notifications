class Investigations::ActivitiesController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  before_action :set_investigation
  before_action :create_activity, only: %i[create]

  def new
    return unless params[:commit] == "Continue"

    case params[:activity_type]
    when "comment"
      redirect_to comment_investigation_activities_path(@investigation)
    when "email"
      redirect_to new_investigation_email_path(@investigation)
    when "phone_call"
      redirect_to new_investigation_phone_call_path(@investigation)
    when "meeting"
      redirect_to new_investigation_meeting_path(@investigation)
    when "product"
      redirect_to new_investigation_product_path(@investigation)
    when "testing_request"
      redirect_to new_request_investigation_tests_path(@investigation)
    when "testing_result"
      redirect_to new_result_investigation_tests_path(@investigation)
    when "corrective_action"
      redirect_to new_investigation_corrective_action_path(@investigation)
    when "business"
      redirect_to new_investigation_business_path(@investigation)
    when "visibility"
      redirect_to visibility_investigation_path(@investigation)
    when "alert"
      redirect_to new_investigation_alert_path(@investigation)
    else
      @activity_type_empty = true
    end
  end

  def comment; end

  # POST /activities
  # POST /activities.json
  def create
    respond_to do |format|
      if @investigation.activities << @activity
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
    @activity = CommentActivity.new(body: Activity.sanitize_text(activity_params[:body]))
    @activity.source = UserSource.new(user: User.current)
  end

  def set_investigation
    @investigation = Investigation.find_by!(pretty_id: params[:investigation_pretty_id])
    authorize @investigation, :show?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def activity_params
    params.require(:comment_activity).permit(:body)
  end
end
