class Investigations::TestsController < ApplicationController
  include FileConcern
  include Wicked::Wizard
  steps :details, :confirmation

  before_action :set_investigation
  before_action :build_test_from_params, only: %i[update]
  before_action :store_test, only: %i[update]
  before_action :restore_test, only: %i[show create]
  before_action :set_attachment, only: %i[show update create]

  # GET /tests/1
  # GET /tests/1.json
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
  # POST /tests.json
  def create
    attach_files
    if @test.save
      redirect_to investigation_url(@investigation), notice: "#{@test.pretty_name.capitalize} was successfully recorded."
    else
      render step
    end
  end

  # PATCH/PUT /tests/1
  # PATCH/PUT /tests/1.json
  def update
    if @test.valid?(step)
      redirect_to next_wizard_path
    else
      render step
    end
  end

private

  def clear_session
    session[:test] = nil
    initialize_file_attachment
  end

  def set_investigation
    @investigation = Investigation.find(params[:investigation_id])
  end

  def set_attachment
    @file = load_file_attachment
  end

  def build_test_from_params
    @test = if params.include? :test
              @investigation.tests.build(test_params)
            else
              @investigation.tests.build
            end
  end

  def store_test
    session[:test] = @test.attributes
  end

  def restore_test
    @test = @investigation.tests.build(session[:test])
  end

  def attach_files
    attach_file_to_list(@file, @test.documents)
    attach_file_to_list(@file, @investigation.documents)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def test_params
    params.require(:test).permit(:product_id,
                                 :legislation,
                                 :type,
                                 :result,
                                 :details,
                                 :day,
                                 :month,
                                 :year)
  end

  def get_file_params_key
    :test
  end

  def file_metadata_params
    if @test.requested?
      title = "Test requested: #{@test.product.name}"
      document_type = "test_request"
    else
      title = "#{@test.result.capitalize} test: #{@test.product.name}"
      document_type = "test_results"
    end
    super.merge(title: title, document_type: document_type)
  end
end
