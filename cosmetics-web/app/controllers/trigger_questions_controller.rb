class TriggerQuestionsController < ApplicationController
  include Wicked::Wizard
  include CpnpNotificationTriggerRules
  include TriggerRulesHelper

  steps :contains_anti_dandruff_agents,
        :add_anti_dandruff_agents

  before_action :set_component
  before_action :set_question

  def show
    initialize_step
    render_wizard
  end

  def update
    case step
    when :contains_anti_dandruff_agents
      render_contains_anti_dandruff_agents
    when :add_anti_dandruff_agents
      render_add_anti_dandruff_agents
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
    question = :please_specify_the_inci_name_and_concentration_of_the_antidandruff_agents_if_antidandruff_agents_are_not_present_in_the_cosmetic_product_then_not_applicable_must_be_checked
    @question = TriggerQuestion.find_or_create_by(component: @component, question: question)
  end

  def initialize_step
    case step
    when :add_anti_dandruff_agents
      populate_answers_for_list
    end
  end

  def render_contains_anti_dandruff_agents
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

  def render_add_anti_dandruff_agents
    @question.update(question_params)
    destroy_invalid_answers

    if @question.trigger_question_elements.empty?
      @errors = [{
                     text: "No substance added",
                     href: "#trigger_question_trigger_question_elements_attributes_0_answer"
                 }]
    end

    re_render_step
  end

  def skip_question
    case step
    when :contains_anti_dandruff_agents
      redirect_to finish_wizard_path
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

  def destroy_invalid_answers
    grouped_answers = @question.trigger_question_elements.group_by(&:answer_order)
    updated_answer_order = 0
    grouped_answers.values.each do |answers|
      if answers.any? { |answer| answer.answer.blank? }
        TriggerQuestionElement.delete(answers)
      else
        answers.each { |answer| answer.update(answer_order: updated_answer_order) }
        updated_answer_order += 1
      end
    end
    @question.reload
  end

  def re_render_step
    initialize_step
    render step
  end

  def question_params
    return {} if params[:trigger_question].blank?

    params.require(:trigger_question).permit(:applicable, trigger_question_elements_attributes: %i[id answer])
  end
end
