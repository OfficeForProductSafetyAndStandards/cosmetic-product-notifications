class InvestigationsController < ApplicationController
  include InvestigationsHelper

  before_action :set_search_params, only: %i[index]
  before_action :set_investigation, only: %i[show update assign status]

  # GET /cases
  # GET /cases.json
  # GET /cases.xlsx
  def index
    # TODO delete unless block when user role exists for The Office
    if !current_user.is_office?
      render "non_office_index"
    end

    respond_to do |format|
      format.html do
        @answer = search_for_investigations(20)
        @results = @answer.results.map { |r| r.merge(record: @answer.records.find_by(id: r._id)) }
        @investigations = @answer.records
      end
      format.xlsx do
        @answer = search_for_investigations
        @investigations = @answer.records
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
    when "question"
      redirect_to new_question_path
    else
      @nothing_selected = true if params[:commit].present?
    end
  end

  # GET /cases/1/status
  def status; end

  # GET /cases/1/assign
  def assign; end

  # PATCH/PUT /cases/1
  # PATCH/PUT /cases/1.json
  def update
    ps = investigation_update_params
    @investigation.is_closed = ps[:is_closed] if ps[:is_closed]
    @investigation.status_rationale = ps[:status_rationale] if ps[:status_rationale]
    @investigation.assignee = User.find_by(id: ps[:assignee_id]) if ps[:assignee_id]
    respond_to do |format|
      if @investigation.save
        format.html { redirect_to @investigation, notice: "Case was successfully updated." }
        format.json { render :show, status: :ok, location: @investigation }
      else
        @investigation.restore_attributes
        origin = if ps[:is_closed]
                   :status
                 else
                   :assign
                 end
        format.html { render origin }
        format.json { render json: @investigation.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /cases
  # POST /cases.json
  def create
    @investigation = Investigation.new(investigation_create_params)
    respond_to do |format|
      if @investigation.save
        format.html { redirect_to investigation_path(@investigation), notice: "Case was successfully created." }
        format.json { render :show, status: :created, location: @investigation }
      else
        format.html { render :new }
        format.json { render json: @investigation.errors, status: :unprocessable_entity }
      end
    end
  end

private

  def set_investigation
    @investigation = Investigation.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def investigation_create_params
    params.require(:investigation).permit(:description)
  end

  def investigation_update_params
    if params[:investigation][:assignee_id].blank?
      params[:investigation][:assignee_id] = params[:investigation][:assignee_id_radio]
    end
    params.require(:investigation).permit(:is_closed, :status_rationale, :assignee_id)
  end
end
