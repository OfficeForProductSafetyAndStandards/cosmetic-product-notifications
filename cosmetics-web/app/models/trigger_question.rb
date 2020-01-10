class TriggerQuestion < ApplicationRecord
  # TODO: make this non-optional after refactoring CpnpParser
  belongs_to :component, optional: true

  has_many :trigger_question_elements, -> { order(answer_order: :asc, element_order: :asc) }, dependent: :destroy, inverse_of: :trigger_question
  accepts_nested_attributes_for :trigger_question_elements

  validates :applicable, inclusion: { in: [true, false] }, on: :update
end
