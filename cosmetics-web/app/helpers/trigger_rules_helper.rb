module TriggerRulesHelper
  def get_formulation_data(question, element)
    if element.element_order == 1
      inciname_incivalue_pair = get_inciname_incivalue_pair(question, element)
      if inciname_incivalue_pair.count > 1
        formulation_data = inciname_incivalue_pair
      end
    end
    formulation_data
  end

  def get_inciname_incivalue_pair(question, element)
    question_id = element.trigger_question_id
    answer_order = element.answer_order
    inciname_incivalue_pair = []
    question.trigger_question_elements.where(
      trigger_question_id: question_id, answer_order: answer_order
    ).each do |question_element|
      inciname_incivalue_pair << question_element.answer
    end
  end

  def format_trigger_question_elements(trigger_question, trigger_question_elements)
    trigger_question_list = []
    trigger_question_elements.where(element: "inciname").each do |element|
      inciname_incivalue_pair = get_inciname_incivalue_pair(trigger_question, element)
      trigger_question_list << {
          inci_name: inciname_incivalue_pair.first.answer,
          quantity: display_concentration(inciname_incivalue_pair.last.answer)
      }
    end
    trigger_question_list
  end

  def format_trigger_question_answers(answer)
    case answer
    when "NA"
      "None"
    when "N"
      "No"
    when "Y"
      "Yes"
    else
      answer
    end
  end
end
