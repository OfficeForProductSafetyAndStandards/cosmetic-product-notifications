class Create::QuestionController < Create::CreationFlowController
  include FileConcern
  set_attachment_names :file
  set_file_params_key :question

  steps :reporter_type, :reporter_details, :question_details

  before_action :set_reporter
  before_action :set_question, only: %i[show create update]
  before_action :set_attachment, only: %i[show create update]
  before_action :update_attachment, only: %i[create update]
  before_action :store_reporter, only: %i[update]
  before_action :store_question, only: %i[update]

  def create
    if question_saved?
      redirect_to investigation_path(@question), notice: "Question was successfully created."
    else
      render step
    end
  end

  def update
    if question_valid?
      if step == steps.last
        create
      else
        redirect_to next_wizard_path
      end
    else
      render step
    end
  end

private

  def clear_session
    super
    session[:question] = nil
    initialize_file_attachments
  end

  def set_question
    @question = Investigation.new(question_params)
  end

  def set_attachment
    @file_blob, * = load_file_attachments
  end

  def update_attachment
    update_blob_metadata @file_blob, file_metadata
  end

  def store_question
    session[:question] = @question.attributes if @question.valid?(step)
  end

  def question_valid?
    @reporter.validate(step)
    @question.validate(step)
    validate_blob_size(@file_blob, @question.errors, "File")
    @reporter.errors.empty? && @question.errors.empty?
  end

  def question_saved?
    return false unless question_valid?

    attach_blobs_to_list(@file_blob, @question.documents)
    @question.reporter = @reporter
    @question.save
  end

  def save_attachment
    @file_blob.save if @file_blob
  end

  def question_params
    question_session_params.merge(question_request_params).merge(is_case: false)
  end

  def question_session_params
    session[:question] || {}
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def question_request_params
    return {} if params[:question].blank?

    params.require(:question).permit(:question_title, :description)
  end

  def file_metadata
    get_attachment_metadata_params(:file).merge(
      title: @file_blob&.filename,
    )
  end
end
