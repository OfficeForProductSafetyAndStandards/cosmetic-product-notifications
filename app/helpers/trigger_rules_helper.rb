module TriggerRulesHelper
  def format_trigger_question_elements(trigger_question_elements)
    trigger_question_elements.group_by(&:answer_order).filter_map do |_answer_order, elements|
      if elements.first.answer.present? && elements.last.answer.present?
        {
          inci_name: elements.first.answer,
          quantity: display_concentration(elements.last.answer),
        }
      end
    end
  end

  def format_trigger_question_answers(answer)
    case answer
    when "NA"
      "None"
    when "N"
      "No"
    else
      answer
    end
  end
end
