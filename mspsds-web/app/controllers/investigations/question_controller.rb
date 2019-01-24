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

  def set_investigation
    @investigation = Investigation::Question.new(investigation_params)
  end

  def success_message
    "Enquiry was successfully created."
  end

  def set_page_title
    @page_title = "New Enquiry"
    @page_subtitle = "Who did the enquiry come from?"
  end
end
