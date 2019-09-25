class TriggerQuestionsController < ApplicationController
  include Wicked::Wizard
  include CpnpNotificationTriggerRules
  include TriggerRulesHelper

  steps :contains_anti_dandruff_agents, :add_anti_dandruff_agents,
        :select_ph_range, :exact_ph, :add_alkaline_agents,
        :contains_anti_hair_loss_agents, :add_anti_hair_loss_agents,
        :contains_anti_pigmenting_agents, :add_anti_pigmenting_agents,
        :contains_chemical_exfoliating_agents, :add_chemical_exfoliating_agents,
        :contains_vitamin_a, :add_vitamin_a,
        :contains_xanthine_derivatives, :add_xanthine_derivatives,
        :contains_cationic_surfactants, :add_cationic_surfactants,
        :contains_propellant, :add_propellant,
        :contains_hydrogen_peroxide, :add_hydrogen_peroxide,
        :contains_compounds_releasing_hydrogen_peroxide, :add_compounds_releasing_hydrogen_peroxide,
        :contains_reducing_agents, :add_reducing_agents,
        :contains_persulfates, :add_persulfates,
        :contains_straightening_agents, :add_straightening_agents,
        :contains_inorganic_sodium_salts, :add_inorganic_sodium_salts,
        :contains_fluoride_compounds, :add_fluoride_compounds,
        :contains_essential_oils, :add_essential_oils,
        :contains_ethanol,
        :contains_isopropanol

  before_action :set_component
  before_action :set_question, only: %i[show update]

  def show
    initialize_step
    render_wizard
  end

  def update
    case step
    when :contains_anti_dandruff_agents,
        :select_ph_range,
        :contains_anti_hair_loss_agents,
        :contains_anti_pigmenting_agents,
        :contains_chemical_exfoliating_agents,
        :contains_vitamin_a,
        :contains_xanthine_derivatives,
        :contains_cationic_surfactants,
        :contains_propellant,
        :contains_hydrogen_peroxide,
        :contains_compounds_releasing_hydrogen_peroxide,
        :contains_reducing_agents,
        :contains_persulfates,
        :contains_straightening_agents,
        :contains_inorganic_sodium_salts,
        :contains_fluoride_compounds,
        :contains_essential_oils
      render_substance_check
    when :add_anti_dandruff_agents,
        :add_alkaline_agents,
        :add_anti_hair_loss_agents,
        :add_anti_pigmenting_agents,
        :add_chemical_exfoliating_agents,
        :add_vitamin_a,
        :add_xanthine_derivatives,
        :add_cationic_surfactants,
        :add_propellant,
        :add_hydrogen_peroxide,
        :add_compounds_releasing_hydrogen_peroxide,
        :add_reducing_agents,
        :add_persulfates,
        :add_straightening_agents,
        :add_inorganic_sodium_salts,
        :add_fluoride_compounds,
        :add_essential_oils
      render_substance_list
    when :contains_ethanol,
        :contains_isopropanol
      render_substance_check_with_condition
    when :exact_ph
      render_exact_ph
    else
      redirect_to finish_wizard_path
    end
  end

  def new
    redirect_to wizard_path(steps.first)
  end

  def finish_wizard_path
    if @component.notification.is_multicomponent?
      responsible_person_notification_build_path(@component.notification.responsible_person, @component.notification, :add_new_component)
    else
      responsible_person_notification_build_path(@component.notification.responsible_person, @component.notification, :add_product_image)
    end
  end

  def previous_wizard_path
    if step == steps.first
      return responsible_person_notification_component_build_path(@component.notification.responsible_person, @component.notification, @component, :select_frame_formulation)

    elsif step == :select_ph_range 
      if @component.predefined?
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
    when :select_ph_range
      :contains_anti_dandruff_agents
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

private

  NUMBER_OF_ANSWERS = 10

  def set_component
    @component = Component.find(params[:component_id])
    authorize @component.notification, policy_class: ResponsiblePersonNotificationPolicy
    @component_name = @component.notification.is_multicomponent? ? @component.name : "the cosmetic product"
  end

  def set_question
    question = get_question_for_step step
    @question = TriggerQuestion.find_or_create_by(component: @component, question: question) if question.present?
  end

  def initialize_step
    case step
    when :add_anti_dandruff_agents,
        :add_alkaline_agents,
        :add_anti_hair_loss_agents,
        :add_anti_pigmenting_agents,
        :add_chemical_exfoliating_agents,
        :add_vitamin_a,
        :add_xanthine_derivatives,
        :add_cationic_surfactants,
        :add_propellant,
        :add_hydrogen_peroxide,
        :add_compounds_releasing_hydrogen_peroxide,
        :add_reducing_agents,
        :add_persulfates,
        :add_straightening_agents,
        :add_inorganic_sodium_salts,
        :add_fluoride_compounds,
        :add_essential_oils
      populate_answers_for_list
    when :exact_ph
      populate_question_with_single_answer :ph
    when :contains_ethanol
      populate_question_with_single_answer :ethanol
    when :contains_isopropanol
      populate_question_with_single_answer :propanol
    when :select_ph_range
      TriggerQuestion.find_or_create_by(component: @component, question: :please_indicate_the_ph)
      TriggerQuestion.find_or_create_by(component: @component, question: :please_indicate_the_inci_name_and_concentration_of_each_alkaline_agent_including_ammonium_hydroxide_liberators)
    end
  end

  def render_exact_ph
    if @question.update_with_context(question_params, @step)
      render_valid_exact_ph(@question.trigger_question_elements.first.answer.to_f)
    else
      re_render_step
    end
  end

  # rubocop:disable Naming/UncommunicativeMethodParamName
  def render_valid_exact_ph(ph)
    alkaline_list_question = @component.trigger_questions.where(question: get_question_for_step(:add_alkaline_agents)).first

    alkaline_list_question.update(applicable: ph > 10)
    if alkaline_list_question.applicable
      render_wizard @component
    else
      alkaline_list_question.trigger_question_elements.destroy_all
      skip_question
    end
  end
  # rubocop:enable Naming/UncommunicativeMethodParamName

  def render_substance_check
    @question.update(question_params)

    return re_render_step if @question.invalid?

    if @question.applicable
      render_wizard @component
    else
      @question.trigger_question_elements.destroy_all
      skip_question
    end
  end

  def render_substance_list
    @question.update(question_params)

    return re_render_step if @question.invalid?

    destroy_empty_answers
    if @question.trigger_question_elements.empty?
      @question.errors.add :substance_list, "No substance added"
      return re_render_step
    end

    @question.update(applicable: true) # ensuring that question is applicable if elements are added to it
    render_wizard @component
  end

  def render_substance_check_with_condition
    @question.update(question_params)

    return re_render_step if @question.invalid?

    @question.trigger_question_elements.destroy_all unless @question.applicable

    render_wizard @component
  end

  def skip_question
    if step == :select_ph_range
      alkaline_list_question = @component.trigger_questions.where(question: get_question_for_step(:add_alkaline_agents)).first
      alkaline_list_question&.destroy
    end

    next_step = get_skip_question_next_step
    redirect_to wizard_path(next_step, component_id: @component.id)
  end

  def get_skip_question_next_step
    case step
    when :contains_anti_dandruff_agents
      :select_ph_range
    when :select_ph_range, :exact_ph
      :contains_anti_hair_loss_agents
    when :contains_anti_hair_loss_agents
      :contains_anti_pigmenting_agents
    when :contains_anti_pigmenting_agents
      :contains_chemical_exfoliating_agents
    when :contains_chemical_exfoliating_agents
      :contains_vitamin_a
    when :contains_vitamin_a
      :contains_xanthine_derivatives
    when :contains_xanthine_derivatives
      :contains_cationic_surfactants
    when :contains_cationic_surfactants
      :contains_propellant
    when :contains_propellant
      :contains_hydrogen_peroxide
    when :contains_hydrogen_peroxide
      :contains_compounds_releasing_hydrogen_peroxide
    when :contains_compounds_releasing_hydrogen_peroxide
      :contains_reducing_agents
    when :contains_reducing_agents
      :contains_persulfates
    when :contains_persulfates
      :contains_straightening_agents
    when :contains_straightening_agents
      :contains_inorganic_sodium_salts
    when :contains_inorganic_sodium_salts
      :contains_fluoride_compounds
    when :contains_fluoride_compounds
      :contains_essential_oils
    when :contains_essential_oils
      :contains_ethanol
    end
  end

  def populate_answers_for_list
    answers_filled = @question.trigger_question_elements.size / 2
    answers_needed = NUMBER_OF_ANSWERS - answers_filled
    answers_needed.times do |index|
      answer_order = index + answers_filled
      @question.trigger_question_elements.build(answer_order: answer_order, element_order: 0, element: :inciname)
      @question.trigger_question_elements.build(answer_order: answer_order, element_order: 1, element: :incivalue)
    end
  end

  def populate_question_with_single_answer(element)
    @question.trigger_question_elements.destroy_all if @question.trigger_question_elements.size > 1
    @question.trigger_question_elements.build(answer_order: 0, element_order: 0, element: element) unless @question.trigger_question_elements.any?
  end

  def destroy_empty_answers
    grouped_answers = @question.trigger_question_elements.group_by(&:answer_order)
    updated_answer_order = 0
    grouped_answers.values.each do |answers|
      if answers.any? { |answer| answer.answer.blank? }
        TriggerQuestionElement.delete(answers)
      else
        answers.each { |answer| answer.update_attribute(:answer_order, updated_answer_order) }
        updated_answer_order += 1
      end
    end
    @question.reload
  end

  def re_render_step
    initialize_step
    render step
  end

  def get_question_for_step(step)
    case step
    when :contains_anti_dandruff_agents, :add_anti_dandruff_agents
      :please_specify_the_inci_name_and_concentration_of_the_antidandruff_agents_if_antidandruff_agents_are_not_present_in_the_cosmetic_product_then_not_applicable_must_be_checked
    when :select_ph_range, :exact_ph
      :please_indicate_the_ph
    when :add_alkaline_agents
      :please_indicate_the_inci_name_and_concentration_of_each_alkaline_agent_including_ammonium_hydroxide_liberators
    when :contains_anti_hair_loss_agents, :add_anti_hair_loss_agents
      :please_specify_the_inci_name_and_concentration_of_the_antihair_loss_agents_if_antihair_loss_agents_are_not_present_in_the_cosmetic_product_then_not_applicable_must_be_checked
    when :contains_anti_pigmenting_agents, :add_anti_pigmenting_agents
      :please_specify_the_inci_name_and_concentration_of_the_antipigmenting_and_depigmenting_agents_if_antipigmenting_and_depigmenting_agents_are_not_present_in_the_cosmetic_product_then_not_applicable_must_be_checked
    when :contains_chemical_exfoliating_agents, :add_chemical_exfoliating_agents
      :please_specify_the_inci_name_and_concentration_of_chemical_exfoliating_agents_if_chemical_exfoliating_agents_are_not_present_in_the_cosmetic_product_then_not_applicable_must_be_checked
    when :contains_vitamin_a, :add_vitamin_a
      :please_specify_the_exact_content_of_vitamin_a_or_its_derivatives_for_the_whole_product_if_the_level_of_vitamin_a_or_any_of_its_derivatives_does_not_exceed_020_calculated_as_retinol_or_if_the_amount_does_not_exceed_009_grams_calculated_as_retinol_or_if_vitamin_a_or_any_of_its_derivatives_are_not_present_in_the_product_then_not_applicable_must_be_checked
    when :contains_xanthine_derivatives, :add_xanthine_derivatives
      :please_specify_the_inci_name_and_the_concentration_of_xanthine_derivatives_eg_caffeine_theophylline_theobromine_plant_extracts_containing_xanthine_derivatives_eg_paulinia_cupana_guarana_extractspowders_if_xanthine_derivatives_are_not_present_or_present_below_05_in_the_cosmetic_product_then_not_applicable_must_be_checked
    when :contains_cationic_surfactants, :add_cationic_surfactants
      :please_specify_the_inci_name_and_concentration_of_the_cationic_surfactants_with_two_or_more_chain_lengths_below_c12_if_the_surfactant_is_used_for_non_preservative_purpose_if_cationic_surfactants_with_two_or_more_chain_lengths_below_c12_are_not_present_in_the_product_then_not_applicable_must_be_checked
    when :contains_propellant, :add_propellant
      :please_specify_the_inci_name_and_concentration_of_each_propellant_if_propellants_are_not_present_in_the_product_then_not_applicable_must_be_checked
    when :contains_hydrogen_peroxide, :add_hydrogen_peroxide
      :please_specify_the_concentration_of_hydrogen_peroxide_if_hydrogen_peroxide_is_not_present_in_the_product_then_not_applicable_must_be_checked_
    when :contains_compounds_releasing_hydrogen_peroxide, :add_compounds_releasing_hydrogen_peroxide
      :please_specify_the_inci_name_and_the_concentration_of_the_compounds_that_release_hydrogen_peroxide_if_compounds_releasing_hydrogen_peroxide_are_not_present_in_the_product_then_not_applicable_must_be_checked
    when :contains_reducing_agents, :add_reducing_agents
      :please_specify_the_inci_name_and_concentration_of_each_reducing_agent_if_reducing_agents_are_not_present_in_the_product_then_not_applicable_must_be_checked
    when :contains_persulfates, :add_persulfates
      :please_specify_the_inci_name_and_concentration_of_each_persulfate_if_persulfates_are_not_present_in_the_product_then_not_applicable_must_be_checked
    when :contains_straightening_agents, :add_straightening_agents
      :please_specify_the_inci_name_and_concentration_of_each_straightening_agent_if_straightening_agents_are_not_present_in_the_product_then_not_applicable_must_be_checked
    when :contains_inorganic_sodium_salts, :add_inorganic_sodium_salts
      :please_indicate_the_total_concentration_of_inorganic_sodium_salts_if_inorganic_sodium_salts_are_not_present_in_the_product_then_not_applicable_must_be_checked
    when :contains_fluoride_compounds, :add_fluoride_compounds
      :please_indicate_the_concentration_of_fluoride_compounds_calculated_as_fluorine_if_fluoride_compounds_are_not_present_in_the_product_then_not_applicable_must_be_checked
    when :contains_essential_oils, :add_essential_oils
      :please_indicate_the_name_and_the_quantity_of_each_essential_oil_camphor_menthol_or_eucalyptol_if_no_individual_essential_oil_camphor_menthol_or_eucalyptol_are_present_with_a_level_higher_than_05_015_in_case_of_camphor_then_not_applicable_must_be_checked
    when :contains_ethanol
      :please_specify_the_percentage_weight_of_ethanol
    when :contains_isopropanol
      :please_specify_the_percentage_weight_of_isopropanol
    end
  end

  def question_params
    return {} if params[:trigger_question].blank?

    params.require(:trigger_question).permit(:applicable, trigger_question_elements_attributes: %i[id answer answer_order element_order element])
  end
end
