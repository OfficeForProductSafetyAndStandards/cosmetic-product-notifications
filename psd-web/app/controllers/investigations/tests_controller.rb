class Investigations::TestsController < ApplicationController
  include TestsHelper
  include FileConcern
  set_attachment_names :file
  set_file_params_key :test

  include Wicked::Wizard
  steps :details, :confirmation

  before_action :set_investigation
  before_action :set_test, only: %i[show create update]
  before_action :set_attachment, only: %i[show create update]
  before_action :store_test, only: %i[update]

  # GET /tests/1
  def show
    render_wizard
  end

  # GET /tests/new_request
  def new_request
    clear_session
    session[:test] = { type: Test::Request.name }
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  # GET /tests/new_result
  def new_result
    clear_session
    session[:test] = { type: Test::Result.name }
    redirect_to wizard_path(steps.first, request.query_parameters)
  end

  # POST /tests
  def create
    if test_saved?
      @file_model.update test_file_metadata
      redirect_to investigation_url(@investigation), flash: { success: "#{@test.pretty_name.capitalize} was successfully recorded." }
    else
      render step
    end
  end

  # PATCH/PUT /tests/1
  def update
    if test_valid?
      @file_model.update test_file_metadata
      redirect_to next_wizard_path
    else
      render step
    end
  end

private

  def clear_session
    session[:test] = nil
    initialize_file_attachments
  end

  def store_test
    session[:test] = @test.attributes
  end

  def test_saved?
    return false unless test_valid?

    # In addition to attaching to the test, we also attach to the investigation, so the file is surfaced in the ui
    @file_model.attach_blobs_to_list(@investigation.documents)
    @test.save
  end

  def test_session_params
    session[:test] || {}
  end
end
