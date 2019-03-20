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
    get_valid_update_hash = Proc.new do |ps|
      potential_assignees = User.where(id: ps[:assignable_id]) + Team.where(id: ps[:assignable_id])
      potential_assignees.first.present? ? { assignee: potential_assignees.first } : {}
    end
    edit(model_keys: %i[assignable_id assignable_type], get_valid_update_hash: get_valid_update_hash,
         custom_params: assignee_update_params,
         error_message: "Select assignee")
  end

  # GET /cases/1/status
  # PUT /cases/1/status
  def status
    get_valid_update_hash = Proc.new { |ps| ps if ps[:is_closed].present? }
    edit(model_keys: %i[is_closed status_rationale], get_valid_update_hash: get_valid_update_hash,
         error_message: "Status should be closed or open")
  end

  # GET /cases/1/visibility
  # PUT /cases/1/visibility
  def visibility
    get_valid_update_hash = Proc.new { |ps| ps if ps[:is_private].present? }
    edit(model_keys: %i[is_private visibility_rationale], get_valid_update_hash: get_valid_update_hash,
         error_message: "Visibility needs to be private or public")
  end

  # GET /cases/1/edit_summary
  # PUT /cases/1/edit_summary
  def edit_summary
    get_valid_update_hash = Proc.new { |ps| ps if ps[:description].present? }
    edit(model_keys: [:description], get_valid_update_hash: get_valid_update_hash,
         error_message: "Summary can not be empty")
  end

private

  def edit(model_keys:, error_message:, get_valid_update_hash:, custom_params: nil)
    return if request.get?

    ps = custom_params || params.require(:investigation).permit(model_keys)
    update_hash = get_valid_update_hash.call(ps)

    if update_hash.blank?
      @investigation.errors.add(model_keys.first, :invalid, message: error_message)
      respond_to_invalid_data
      return
    end

    update_hash.each do |key, value|
      @investigation.send("#{key}=", value) if value
    end

    respond_to_update
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

  def assignee_update_params
    return {} if params[:investigation].blank?

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

  def respond_to_update
    respond_to do |format|
      if @investigation.save
        format.html { redirect_to @investigation, notice: "#{@investigation.case_type.titleize} was successfully updated." }
        format.json { render :show, status: :ok, location: @investigation }
      else
        @investigation.restore_attributes
        format.html { render action_name }
        format.json { render json: @investigation.errors, status: :unprocessable_entity }
      end
    end
  end

  def respond_to_invalid_data
    respond_to do |format|
      format.html { render action_name }
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
