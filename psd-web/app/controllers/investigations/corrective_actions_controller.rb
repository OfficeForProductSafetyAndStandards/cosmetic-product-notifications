class Investigations::CorrectiveActionsController < ApplicationController
  include CorrectiveActionsConcern
  include FileConcern
  set_attachment_names :file
  set_file_params_key :corrective_action

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
      if corrective_action_saved?
        @file_model.update_file corrective_action_file_metadata
        format.html { redirect_to investigation_url(@investigation), flash: { success: "Corrective action was successfully recorded." } }
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
        @file_model.update_file corrective_action_file_metadata
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
    initialize_file_attachments
  end

  def store_corrective_action
    session[:corrective_action] = @corrective_action.attributes if @corrective_action.valid?(step)
  end

  def corrective_action_saved?
    return false unless corrective_action_valid?

    # In addition to attaching to the test, we also attach to the investigation, so the file is surfaced in the ui
    @file_model.attach_blob_to_list(@investigation.documents)
    @corrective_action.save
  end

  def corrective_action_session_params
    session[:corrective_action] || {}
  end
end
