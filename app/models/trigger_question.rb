class TriggerQuestion < ApplicationRecord
  PH_QUESTION = "please_indicate_the_ph".freeze

  belongs_to :component

  has_many :trigger_question_elements, -> { order(answer_order: :asc, element_order: :asc) }, dependent: :destroy, inverse_of: :trigger_question
  accepts_nested_attributes_for :trigger_question_elements

  validates :applicable, inclusion: { in: [true, false] }, on: :update

  def ph_question?
    question == PH_QUESTION
  end
end
