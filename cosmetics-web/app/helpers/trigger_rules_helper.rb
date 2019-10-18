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

  def format_trigger_question_elements(trigger_question_elements)
    trigger_question_elements.group_by(&:answer_order).map do |_answer_order, elements|
      {
          inci_name: elements.first.answer,
          quantity: display_concentration(elements.last.answer)
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
    if (step == steps.first) || (step == :select_ph_range) # Temporary fix since anti-dandruff questions are supposed to be skipped and due to be removed separately.
      if @component.predefined? && !@component.contains_poisonous_ingredients?
        return responsible_person_notification_component_build_path(@component.notification.responsible_person, @component.notification, @component, :contains_poisonous_ingredients)
      else
        return responsible_person_notification_component_build_path(@component.notification.responsible_person, @component.notification, @component, :upload_formulation)
      end
    end

    previous_step = get_previous_step

    if !previous_step.nil?
      responsible_person_notification_component_trigger_question_path(@component.notification.responsible_person, @component.notification, @component, previous_step)
    else
      super
    end
  end

  def get_previous_step
    case step
    when :contains_anti_hair_loss_agents
      :select_ph_range
    when :contains_anti_pigmenting_agents
      :contains_anti_hair_loss_agents
    when :contains_chemical_exfoliating_agents
      :contains_anti_pigmenting_agents
    when :contains_vitamin_a
      :contains_chemical_exfoliating_agents
    when :contains_xanthine_derivatives
      :contains_vitamin_a
    when :contains_cationic_surfactants
      :contains_xanthine_derivatives
    when :contains_propellant
      :contains_cationic_surfactants
    when :contains_hydrogen_peroxide
      :contains_propellant
    when :contains_compounds_releasing_hydrogen_peroxide
      :contains_hydrogen_peroxide
    when :contains_reducing_agents
      :contains_compounds_releasing_hydrogen_peroxide
    when :contains_persulfates
      :contains_reducing_agents
    when :contains_straightening_agents
      :contains_persulfates
    when :contains_inorganic_sodium_salts
      :contains_straightening_agents
    when :contains_fluoride_compounds
      :contains_inorganic_sodium_salts
    when :contains_essential_oils
      :contains_fluoride_compounds
    when :contains_ethanol
      :contains_essential_oils
    end
  end
end
