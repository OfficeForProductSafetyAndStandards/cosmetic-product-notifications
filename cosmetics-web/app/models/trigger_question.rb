class TriggerQuestion < ApplicationRecord
  belongs_to :component

  has_many :trigger_question_elements
end
