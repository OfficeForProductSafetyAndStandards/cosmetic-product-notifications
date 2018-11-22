class Investigations::CorrectiveActionsController < ApplicationController
  include FileConcern
  include Wicked::Wizard
  steps :details, :confirmation

  before_action :set_investigation
  before_action :set_corrective_action, only: %i[show create update]
  before_action :set_attachment, only: %i[show create update]
  before_action :store_corrective_action, only: %i[update]

  # GET /corrective_actions/1
  def show
    render_wizard
  end

  # GET /corrective_actions/new
  def new
    clear_session
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  # POST /corrective_actions
  # POST /corrective_actions.json
  def create
    respond_to do |format|
      attach_files
      if @corrective_action.save
        format.html { redirect_to investigation_url(@investigation), notice: "Corrective action was successfully recorded." }
        format.json { render :show, status: :created, location: @corrective_action }
      else
        format.html { render step }
        format.json { render json: @corrective_action.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /corrective_actions/1
  # PATCH/PUT /corrective_actions/1.json
  def update
    respond_to do |format|
      if corrective_action_valid?
        format.html { redirect_to next_wizard_path }
        format.json { render :show, status: :ok, location: @corrective_action }
      else
        format.html { render step }
        format.json { render json: @corrective_action.errors, status: :unprocessable_entity }
      end
    end
  end

private

  def clear_session
    session[:corrective_action] = nil
    initialize_file_attachment
  end

  def set_investigation
    @investigation = Investigation.find(params[:investigation_id])
  end

  def set_corrective_action
    @corrective_action = @investigation.corrective_actions.build(corrective_action_params)
  end

  def set_attachment
    @file = load_file_attachment
  end

  def store_corrective_action
    session[:corrective_action] = @corrective_action.attributes
  end

  def corrective_action_valid?
    @corrective_action.validate(step)
    validate_blob_size(@file, @corrective_action.errors)
    @corrective_action.errors.empty?
  end

  def attach_files
    attach_file_to_list(@file, @corrective_action.documents)
    attach_file_to_list(@file, @investigation.documents)
  end

  def corrective_action_params
    session_params.merge(request_params)
  end

  def session_params
    session[:corrective_action] || {}
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def request_params
    return {} if params[:corrective_action].blank?

    params.require(:corrective_action).permit(:product_id,
                                              :business_id,
                                              :legislation,
                                              :summary,
                                              :details,
                                              :day,
                                              :month,
                                              :year)
  end

  def file_metadata_params
    super.merge(
      title: @corrective_action.summary,
      other_type: "Corrective action document",
      document_type: :other
    )
  end

  def get_file_params_key
    :corrective_action
  end
end
