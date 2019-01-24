class InvestigationsController < ApplicationController
  include InvestigationsHelper
  include Pundit
  include LoadHelper

  before_action :set_search_params, only: %i[index]
  before_action :set_investigation, only: %i[assign status visibility]
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
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: @investigation.id.to_s
      end
    end
  end

  # GET /cases/new
  def new
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
  # PUT /cases/1/status
  def status
    return if request.get?

    ps = status_update_params
    if ps[:is_closed].blank?
      @investigation.errors.add(:status, :invalid, message: "Status should be closed or open")
      respond_to_invalid_data(:status)
      return
    end

    @investigation.is_closed = ps[:is_closed]
    @investigation.status_rationale = ps[:status_rationale] if ps[:status_rationale]
    respond_to_update(:status)
  end

  # GET /cases/1/assign
  # PUT /cases/1/assign
  def assign
    return if request.get?

    ps = assignee_update_params
    if User.where(id: ps[:assignee_id]).empty?
      @investigation.errors.add(:assignee, :invalid, message: "should exist")
      respond_to_invalid_data(:assign)
      return
    end

    @investigation.assignee = User.find_by(id: ps[:assignee_id])
    respond_to_update(:assign)
  end

  # GET /cases/1/visibility
  # PUT /cases/1/visibility
  def visibility
    return if request.get?

    ps = visibility_update_params
    if ps[:is_private].blank?
      @investigation.errors.add(:pretty_visibility, :invalid, message: "Visibility needs to be private or public")
      respond_to_invalid_data(:visibility)
      return
    end

    @investigation.is_private = ps[:is_private]
    respond_to_update(:visibility)
  end

private

  def set_investigation_with_associations
    @investigation = Investigation.eager_load(:source,
                                              products: { documents_attachments: :blob },
                                              investigation_businesses: { business: :locations },
                                              documents_attachments: :blob).find(params[:id])
    authorize @investigation, :show?
    preload_activities
  end

  def set_investigation
    @investigation = Investigation.find(params[:id])
    authorize @investigation, :show?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def investigation_create_params
    params.require(:investigation).permit(:description)
  end

  def status_update_params
    params.require(:investigation).permit(:is_closed, :status_rationale)
  end

  def visibility_update_params
    params.require(:investigation).permit(:is_private)
  end

  def assignee_update_params
    if params[:investigation][:assignee_id].blank?
      params[:investigation][:assignee_id] = params[:investigation][:assignee_id_radio]
    end
    params.require(:investigation).permit(:assignee_id)
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
end
