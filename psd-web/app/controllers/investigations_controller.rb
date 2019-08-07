class InvestigationsController < ApplicationController
  include InvestigationsHelper
  include LoadHelper

  before_action :set_search_params, only: %i[index]
  before_action :set_investigation, only: %i[status visibility edit_summary created]
  before_action :set_investigation_with_associations, only: %i[show]
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
    @current = request.fullpath.split("/").last
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

  # GET /cases/1/status
  # PATCH /cases/1/status
  def status
    update
  end

  # GET /cases/1/visibility
  # PATCH /cases/1/visibility
  def visibility
    update
  end

  # GET /cases/1/edit_summary
  # PATCH /cases/1/edit_summary
  def edit_summary
    update
  end

  def created; end

private

  def update
    return if request.get?

    respond_to do |format|
      if @investigation.update(update_params)
        format.html {
          redirect_to @investigation, flash: {
            success: "#{@investigation.case_type.titleize} was successfully updated."
          }
        }
        format.json { render :show, status: :ok, location: @investigation }
      else
        format.html { render action_name }
        format.json { render json: @investigation.errors, status: :unprocessable_entity }
      end
    end
  end

  def set_investigation_with_associations
    id = params[:pretty_id] || params[:investigation_pretty_id]
    @investigation = Investigation.eager_load(:source,
                                              products: { documents_attachments: :blob },
                                              investigation_businesses: { business: :locations },
                                              documents_attachments: :blob).find_by!(pretty_id: id)
    authorize @investigation, :show?
    preload_activities
  end

  def set_investigation
    @investigation = Investigation.find_by!(pretty_id: params[:pretty_id])
    authorize @investigation
  end

  def update_params
    return {} if params[:investigation].blank?

    params.require(:investigation).permit(editable_keys)
  end

  def editable_keys
    %i[description is_closed status_rationale is_private visibility_rationale]
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
