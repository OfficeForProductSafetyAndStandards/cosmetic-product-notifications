class TriggerQuestion < ApplicationRecord
  belongs_to :component

  has_many :trigger_question_elements, dependent: :destroy

  def not_applicable?
    (trigger_question_elements.count == 1 &&
        trigger_question_elements.first.element == "inciname" &&
        trigger_question_elements.first.answer == "NA")
  end
end
