class Investigations::QuestionController < Investigations::CreationFlowController
  set_attachment_names :attachment
  set_file_params_key :question

  steps :reporter, :reporter_details, :question_details

private

  def model_key
    :question
  end

  def model_params
    %i[question_title description]
  end

  def success_message
    "Question was successfully created."
  end

  def investigation_params
    super.merge(is_case: false)
  end
end
