module TestsHelper
  def set_investigation
    @investigation = Investigation.find_by!(pretty_id: params[:investigation_pretty_id])
    authorize @investigation, :show?
  end

  def set_test
    @test = @investigation.tests.build(test_params)
  end

  def test_params
    test_session_params.merge(test_request_params)
  end

  def set_attachment
    @file_blob, * = load_file_attachments
    @test.documents.attach(@file_blob) if @file_blob
  end

  def update_attachment
    @test.update_blob_metadata @file_blob, test_file_metadata
  end

  def test_valid?
    @test.validate
    @test.validate_blob_size(@file_blob, @test.errors, "file")
    @test.errors.empty?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def test_request_params
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

  def test_file_metadata
    if @test.requested?
      title = "Test requested: #{@test.product&.name}"
      document_type = "test_request"
    else
      title = "#{@test.result&.capitalize} test: #{@test.product&.name}"
      document_type = "test_results"
    end
    get_attachment_metadata_params(:file).merge(title: title, document_type: document_type)
  end

  def model_type
    params.dig(:test, :is_result) == "true" ? Test::Result.name : Test::Request.name
  end
end
