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
      trigger_question_id: question_id, answer_order: answer_order,
    ).each do |question_element|
      inciname_incivalue_pair << question_element.answer
    end
  end

  def format_trigger_question_elements(trigger_question_elements)
    trigger_question_elements.group_by(&:answer_order).map do |_answer_order, elements|
      {
          inci_name: elements.first.answer,
          quantity: display_concentration(elements.last.answer),
      }
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

  def previous_wizard_path
    case step
    when :ph
      wizard_path(:select_ph_range)
    when :select_ph_range

      previous_step =
        if @component.predefined? && !@component.contains_poisonous_ingredients?
          :contains_poisonous_ingredients
        else
          :upload_formulation
        end

      responsible_person_notification_component_build_path(@component.notification.responsible_person, @component.notification, @component, previous_step)
    end
  end
end
