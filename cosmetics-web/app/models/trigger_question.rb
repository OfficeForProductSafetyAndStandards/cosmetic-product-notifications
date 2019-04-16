class TriggerQuestion < ApplicationRecord
  belongs_to :component

  has_many :trigger_question_elements, -> { order(answer_order: :asc, element_order: :asc) }, dependent: :destroy, inverse_of: :trigger_question
  accepts_nested_attributes_for :trigger_question_elements

  validates :applicable, inclusion: { in: [true, false] }, on: :update

  def applicable?
    applicable && applicable_inciname && applicable_ph
  end

private

  def applicable_inciname
    !(trigger_question_elements.size == 1 &&
        trigger_question_elements.first.element == "inciname" &&
        trigger_question_elements.first.answer == "NA")
  end

  def applicable_ph
    !(trigger_question_elements.size == 1 &&
        trigger_question_elements.first.element == "ph" &&
        trigger_question_elements.first.answer == "N")
  end
end
