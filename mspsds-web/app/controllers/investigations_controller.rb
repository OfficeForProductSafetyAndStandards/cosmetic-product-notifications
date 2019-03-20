class InvestigationsController < ApplicationController
  include InvestigationsHelper
  include LoadHelper

  before_action :set_search_params, only: %i[index]
  before_action :set_investigation, only: %i[assign status visibility edit_summary]
  before_action :set_investigation_with_associations, only: %i[show]
  before_action :set_suggested_previous_assignees, only: :assign
  before_action :build_breadcrumbs, only: %i[show]

  # GET /cases
  # GET /cases.json
  # GET /cases.xlsx
  def index
    respond_to do |format|
      format.html do
        @answer = search_for_investigations(20)
        records = Investigation.eager_load(:products, :source).where(id: @answer.results.map(&:_id))
        @results = @answer.results.map { |r| r.merge(record: records.detect { |rec| rec.id.to_s == r._id }) }
        @investigations = @answer.records
      end
      format.xlsx do
        @answer = search_for_investigations
        @investigations = Investigation.eager_load(:complainant,
                                                   :source,
                                                   { products: :source },
                                                   { activities: :source },
                                                   { businesses: %i[locations source] },
                                                   :corrective_actions,
                                                   :correspondences,
                                                   :tests).where(id: @answer.results.map(&:_id))
      end
    end
  end

  # GET /cases/1
  # GET /cases/1.json
  def show
    respond_to do |format|
      format.html
    end
  end

  # GET /cases/new
  def new
    return redirect_to new_ts_investigation_path unless User.current.is_opss?

    case params[:type]
    when "allegation"
      redirect_to new_allegation_path
    when "enquiry"
      redirect_to new_enquiry_path
    when "project"
      redirect_to new_project_path
    else
      @nothing_selected = true if params[:commit].present?
    end
  end

  # GET /cases/1/assign
  # PUT /cases/1/assign
  def assign
    return if request.get?

    ps = assignee_update_params

    potential_assignees = User.where(id: ps[:assignable_id]) + Team.where(id: ps[:assignable_id])
    if potential_assignees.empty?
      @investigation.errors.add(:assignable_id, :invalid, message: "Select assignee")
      respond_to_invalid_data(:assign)
      return
    end
    @investigation.assignee = potential_assignees.first
    respond_to_update(:assign)
  end

  # GET /cases/1/status
  # PUT /cases/1/status
  def status
    edit(model_keys: %i[is_closed status_rationale], action_key: :status,
         error_message: "Status should be closed or open")
  end

  # GET /cases/1/visibility
  # PUT /cases/1/visibility
  def visibility
    edit(model_keys: %i[is_private visibility_rationale], action_key: :visibility,
         error_message: "Visibility needs to be private or public")
  end

  # GET /cases/1/edit_summary
  # PUT /cases/1/edit_summary
  def edit_summary
    edit(model_keys: [:description], action_key: :edit_summary, error_message: "Summary can't be empty")
  end

private

  def edit(model_keys:, action_key:, error_message:)
    return if request.get?

    ps = params.require(:investigation).permit(model_keys)
    important_model_key = model_keys.first

    if ps[important_model_key].blank?
      @investigation.errors.add(important_model_key, :invalid, message: error_message)
      respond_to_invalid_data(action_key)
      return
    end

    model_keys.each do |model_key|
      @investigation.send("#{model_key}=", ps[model_key]) if ps[model_key]
    end

    respond_to_update(action_key)
  end

  def set_investigation_with_associations
    @investigation = Investigation.eager_load(:source,
                                              products: { documents_attachments: :blob },
                                              investigation_businesses: { business: :locations },
                                              documents_attachments: :blob).find_by!(pretty_id: params[:pretty_id])
    authorize @investigation, :show?
    preload_activities
  end

  def set_investigation
    @investigation = Investigation.find_by!(pretty_id: params[:pretty_id])
    authorize @investigation
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def investigation_create_params
    params.require(:investigation).permit(:description)
  end

  def status_update_params
    params.require(:investigation).permit(:is_closed, :status_rationale)
  end

  def visibility_update_params
    params.require(:investigation).permit(:is_private, :visibility_rationale)
  end

  def edit_summary_update_params
    params.require(:investigation).permit(:description)
  end

  def assignee_update_params
    params[:investigation][:assignable_id] = case params[:investigation][:assignable_id]
                                             when "someone_in_your_team"
                                               params[:investigation][:select_team_member]
                                             when "previously_assigned"
                                               params[:investigation][:select_previously_assigned]
                                             when "other_team"
                                               params[:investigation][:select_other_team]
                                             when "someone_else"
                                               params[:investigation][:select_someone_else]
                                             else
                                               params[:investigation][:assignable_id]
                                             end
    params.require(:investigation).permit(:assignable_id)
  end

  def respond_to_update(origin)
    respond_to do |format|
      if @investigation.save
        format.html { redirect_to @investigation, notice: "#{@investigation.case_type.titleize} was successfully updated." }
        format.json { render :show, status: :ok, location: @investigation }
      else
        @investigation.restore_attributes
        format.html { render origin }
        format.json { render json: @investigation.errors, status: :unprocessable_entity }
      end
    end
  end

  def respond_to_invalid_data(origin)
    respond_to do |format|
      format.html { render origin }
      format.json { render json: @investigation.errors, status: :unprocessable_entity }
    end
  end

  def preload_activities
    @activities = @investigation.activities.eager_load(:source)
    preload_manually(@activities.select { |a| a.respond_to?("attachment") },
                     [{ attachment_attachment: :blob }])
    preload_manually(@activities.select { |a| a.respond_to?("email_file") },
                     [{ email_file_attachment: :blob }, { email_attachment_attachment: :blob }])
    preload_manually(@activities.select { |a| a.respond_to?("transcript") },
                     [{ transcript_attachment: :blob }, { related_attachment_attachment: :blob }])
    preload_manually(@activities.select { |a| a.respond_to?("correspondence") },
                     [:correspondence])
  end

  def build_breadcrumbs
    @breadcrumbs = build_breadcrumb_structure
  end

  def set_suggested_previous_assignees
    @suggested_previous_assignees = suggested_previous_assignees
  end
end
