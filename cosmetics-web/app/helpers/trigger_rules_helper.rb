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
        {trigger_question_id: question_id, answer_order: answer_order}).each do |question_element|
      inciname_incivalue_pair << question_element.answer
    end
    p inciname_incivalue_pair
  end
end

