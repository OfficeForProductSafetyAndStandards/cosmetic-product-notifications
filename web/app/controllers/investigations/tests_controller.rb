class Investigations::TestsController < ApplicationController
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
    update_attachment
    if test_saved?
      save_attachment
      redirect_to investigation_url(@investigation),
                    notice: "#{@test.pretty_name.capitalize} was successfully recorded."
    else
      render step
    end
  end

  # PATCH/PUT /tests/1
  def update
    update_attachment
    if test_valid?
      save_attachment
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

  def set_investigation
    @investigation = Investigation.find(params[:investigation_id])
  end

  def set_test
    @test = @investigation.tests.build(test_params)
  end

  def set_attachment
    @file_blob, * = load_file_attachments
  end

  def update_attachment
    update_blob_metadata @file_blob, file_metadata
  end

  def store_test
    session[:test] = @test.attributes
  end

  def test_saved?
    return false unless test_valid?
    attach_files
    @test.save
  end

  def test_valid?
    @test.validate(step)
    validate_blob_size(@file_blob, @test.errors, "file")
    @test.errors.empty?
  end

  def attach_files
    attach_blobs_to_list(@file_blob, @test.documents)
    attach_blobs_to_list(@file_blob, @investigation.documents)
  end

  def save_attachment
    @file_blob.save if @file_blob
  end

  def test_params
    session_params.merge(request_params).to_h.except(:description)
  end

  def session_params
    session[:test] || {}
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def request_params
    return {} if params[:test].blank?

    params.require(:test)
        .permit(:product_id,
                :legislation,
                :result,
                :details,
                :day,
                :month,
                :year)
        .merge(type: model_type)
  end

  def model_type
    params.dig(:test, :is_result) == "true" ? Test::Result.name : Test::Request.name
  end

  # TODO push this into params
  def file_metadata
    if @test.requested?
      title = "Test requested: #{@test.product&.name}"
      document_type = "test_request"
    else
      title = "#{@test.result&.capitalize} test: #{@test.product&.name}"
      document_type = "test_results"
    end
    get_attachment_metadata_params(:file).merge(title: title, document_type: document_type)
  end
end
