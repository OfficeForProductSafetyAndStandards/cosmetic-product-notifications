class Investigations::QuestionController < Investigations::CreationFlowController
  set_attachment_names :attachment
  set_file_params_key :question

  steps :reporter, :reporter_details, :question_details

private

  def model_key
    :question
  end

  def model_params
    %i[user_title description]
  end

  def success_message
    "Question was successfully created."
  end

  def set_page_title
    @page_title = "New Question"
    @page_subtitle = "Who did the question come from?"
  end

  def investigation_params
    super.merge(case_type: "question")
  end
end
