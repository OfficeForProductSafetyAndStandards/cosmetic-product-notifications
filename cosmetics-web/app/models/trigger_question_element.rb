class TriggerQuestionElement < ApplicationRecord
  belongs_to :trigger_question

  validates :answer, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 14 }, if: -> { question_is_applicable? && self.ph? }
  validates :answer, presence: true, if: -> { question_is_applicable? && answer_is_single_value? }
  validate :no_empty_answers_within_grouped_answers?, if: -> { question_is_applicable? && answer_is_grouped_value? }
  validate :ph_not_between_3_and_10?, on: :exact_ph

  enum element: {
      ethanol: "ethanol",
      propanol: "propanol",
      inciname: "inciname",
      incivalue: "incivalue",
      value: "value",
      ph: "ph",
      concentration: "concentration",
      minrangevalue: "minrangevalue",
      maxrangevalue: "maxrangevalue"
  }

private

  def no_empty_answers_within_grouped_answers?
    answers_with_same_answer_order = trigger_question.trigger_question_elements.find_all { |x| x.answer_order == answer_order }

    if answer.blank? && answers_with_same_answer_order.map(&:answer).any?(&:present?)
      errors.add(:answer, "Must not be blank")
    end
  end

  def ph_not_between_3_and_10?
    ph = answer&.to_f

    errors.add(:answer, "pH must be below 3 or above 10") if ph.between?(3, 10)
  end

  def question_is_applicable?
    trigger_question&.applicable?
  end

  def answer_is_single_value?
    self.ethanol? || self.propanol? || self.ph? || self.value?
  end

  def answer_is_grouped_value?
    self.inciname? || self.incivalue?
  end
end
