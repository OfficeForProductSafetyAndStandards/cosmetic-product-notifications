module TriggerQuestionHelper
  def trigger_question_answer_is_present?(question)
    if question.trigger_question_elements.count == 1 &&
        question.trigger_question_elements.first.element == "inciname" &&
        question.trigger_question_elements.first.answer == "NA"
      false
    else
      true
    end
  end
end
