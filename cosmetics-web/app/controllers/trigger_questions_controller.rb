class TriggerQuestionsController < ApplicationController
  include Wicked::Wizard
  include CpnpNotificationTriggerRules
  include TriggerRulesHelper

  steps :contains_anti_dandruff_agents, :add_anti_dandruff_agents,
        :select_ph_range, :exact_ph, :add_alkaline_agents,
        :ph_mixed_hair_dye,
        :contains_ethanol

  before_action :set_component
  before_action :set_question

  def show
    initialize_step
    render_wizard
  end

  def update
    case step
    when :contains_anti_dandruff_agents
      render_substance_check
    when :add_anti_dandruff_agents
      render_substance_list
    when :select_ph_range
      render_select_ph_range
    when :exact_ph
      render_exact_ph
    when :add_alkaline_agents
      render_substance_list
    when :ph_mixed_hair_dye
      render_substance_check_with_condition
    when :contains_ethanol
      render_substance_check_with_condition
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

private

  NUMBER_OF_ANSWERS = 10

  def set_component
    @component = Component.find(params[:component_id])
  end

  def set_question
    question = get_question_for_step step
    @question = TriggerQuestion.find_or_create_by(component: @component, question: question)
  end

  def initialize_step
    case step
    when :add_anti_dandruff_agents
      populate_answers_for_list
    when :select_ph_range
      TriggerQuestion.find_or_create_by(component: @component, question: :please_indicate_the_ph)
      TriggerQuestion.find_or_create_by(component: @component, question: :please_indicate_the_inci_name_and_concentration_of_each_alkaline_agent_including_ammonium_hydroxide_liberators)
    when :exact_ph
      populate_question_with_single_answer :ph
    when :add_alkaline_agents
      populate_answers_for_list
    when :ph_mixed_hair_dye
      populate_question_with_single_answer :ph
    when :contains_ethanol
      populate_question_with_single_answer :ethanol
    end
  end

  def render_select_ph_range
    selected_value = params[:range]
    exact_ph_question = @component.trigger_questions.where(question: get_question_for_step(:exact_ph)).first
    alkaline_list_question = @component.trigger_questions.where(question: get_question_for_step(:add_alkaline_agents)).first

    case selected_value
    when "below"
      exact_ph_question.update(applicable: true)
      alkaline_list_question.update(applicable: false)
      alkaline_list_question.trigger_question_elements.destroy_all
      render_wizard @component
    when "between"
      exact_ph_question.update(applicable: false)
      exact_ph_question.trigger_question_elements.destroy_all
      alkaline_list_question.update(applicable: false)
      alkaline_list_question.trigger_question_elements.destroy_all
      skip_question
    when "above"
      exact_ph_question.update(applicable: true)
      alkaline_list_question.update(applicable: true)
      render_wizard @component
    else
      @errors = [{ text: "Select an option", href: "#trigger_question_applicable_true" }]
      re_render_step
    end
  end

  def render_exact_ph
    @question.update(question_params)

    if @component.trigger_questions.where(question: get_question_for_step(:add_alkaline_agents), applicable: true).any?
      render_wizard @component
    else
      skip_question
    end
  end

  def render_substance_check
    @question.update(question_params)
    if @question.applicable.nil?
      @errors = [{ text: "Select an option", href: "#trigger_question_applicable_true" }]
      return re_render_step
    end

    if @question.applicable
      render_wizard @component
    else
      @question.trigger_question_elements.destroy_all
      skip_question
    end
  end

  def render_substance_list
    @question.update(question_params)
    destroy_invalid_answers

    if @question.trigger_question_elements.empty?
      define_errors_for_answers "No substance added"
      return re_render_step
    end

    @question.update(applicable: true) # ensuring that question is applicable if elements are added to it
    render_wizard @component
  end

  def render_substance_text_input
    @question.update(question_params)

    if @question.trigger_question_elements.first.answer.blank?
      define_errors_for_answers "No value added"
      return re_render_step
    end

    render_wizard @component
  end

  def render_substance_check_with_condition
    @question.update(question_params)

    return re_render_step unless @question.valid?

    if @question.applicable.nil?
      @errors = [{ text: "Select an option", href: "#trigger_question_applicable_true" }]
      return re_render_step
    end
    @question.trigger_question_elements.destroy_all unless @question.applicable

    if @question.applicable && @question.trigger_question_elements.first.answer.blank?
      define_errors_for_answers "No value added"
      return re_render_step
    end

    render_wizard @component
  end

  def skip_question
    next_step = get_skip_question_next_step
    redirect_to wizard_path(next_step, component_id: @component.id)
  end

  def get_skip_question_next_step
    case step
    when :contains_anti_dandruff_agents
      :select_ph_range
    when :select_ph_range
      :ph_mixed_hair_dye
    when :exact_ph
      :ph_mixed_hair_dye
    end
  end

  def populate_answers_for_list
    answers_filled = @question.trigger_question_elements.count / 2
    answers_needed = NUMBER_OF_ANSWERS - answers_filled
    answers_needed.times do |index|
      answer_order = index + answers_filled
      @question.trigger_question_elements.create(answer_order: answer_order, element_order: 0, element: :inciname)
      @question.trigger_question_elements.create(answer_order: answer_order, element_order: 1, element: :incivalue)
    end
  end

  def populate_question_with_single_answer(element)
    @question.trigger_question_elements.destroy_all if @question.trigger_question_elements.count > 1
    trigger_question = TriggerQuestionElement.find_or_create_by(trigger_question: @question)
    trigger_question.update_attribute(:answer_order, 0)
    trigger_question.update_attribute(:element_order, 0)
    trigger_question.update_attribute(:element, element)
    @question.reload
  end

  def destroy_invalid_answers
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

  def define_errors_for_answers(text)
    @errors = [{ text: text, href: "#trigger_question_trigger_question_elements_attributes_0_answer" }]
  end

  def get_question_for_step(step)
    case step
    when :contains_anti_dandruff_agents
      :please_specify_the_inci_name_and_concentration_of_the_antidandruff_agents_if_antidandruff_agents_are_not_present_in_the_cosmetic_product_then_not_applicable_must_be_checked
    when :add_anti_dandruff_agents
      :please_specify_the_inci_name_and_concentration_of_the_antidandruff_agents_if_antidandruff_agents_are_not_present_in_the_cosmetic_product_then_not_applicable_must_be_checked
    when :exact_ph
      :please_indicate_the_ph
    when :add_alkaline_agents
      :please_indicate_the_inci_name_and_concentration_of_each_alkaline_agent_including_ammonium_hydroxide_liberators
    when :ph_mixed_hair_dye
      :please_indicate_the_ph_of_the_mixed_hair_dye_product
    when :contains_ethanol
      :please_specify_the_percentage_weight_of_ethanol
    end
  end

  def question_params
    return {} if params[:trigger_question].blank?

    params.require(:trigger_question).permit(:applicable, trigger_question_elements_attributes: %i[id answer])
  end
end
