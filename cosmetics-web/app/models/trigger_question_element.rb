class TriggerQuestionElement < ApplicationRecord
  belongs_to :trigger_question

  validates :answer, numericality: true, if: -> { applicable_question? && is_ph? }
  validates :answer, presence: true, if: -> { applicable_question? && is_ethanol_or_isopropanol? }
  validate :no_empty_answers_with_the_same_answer_order, if: -> { applicable_question? && :is_inciname_or_incivalue? }

private

  def no_empty_answers_with_the_same_answer_order
    answers_with_same_answer_order = trigger_question.trigger_question_elements.find_all { |x| x.answer_order == answer_order }

    if answer.blank? && answers_with_same_answer_order.map(&:answer).any?(&:present?)
      errors.add(:answer, "Must not be blank")
    end
  end

  def applicable_question?
    trigger_question.present? && trigger_question.applicable?
  end

  def is_ph?
    element == "ph"
  end

  def is_inciname_or_incivalue?
    element == "inciname" || element == "incivalue"
  end

  def is_ethanol_or_isopropanol?
    element == "ethanol" || element == "isopropanol"
  end
end
