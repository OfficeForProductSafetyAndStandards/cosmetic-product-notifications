class TriggerQuestion < ApplicationRecord
  PH_QUESTION = "please_indicate_the_ph".freeze

  # TODO: make this non-optional after refactoring CpnpParser
  belongs_to :component, optional: true

  has_many :trigger_question_elements, -> { order(answer_order: :asc, element_order: :asc) }, dependent: :destroy, inverse_of: :trigger_question
  accepts_nested_attributes_for :trigger_question_elements

  validates :applicable, inclusion: { in: [true, false] }, on: :update

  def ph_question?
    question == PH_QUESTION
  end
end
