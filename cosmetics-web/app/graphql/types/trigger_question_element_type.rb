module Types
  class TriggerQuestionElementType < Types::BaseObject
    field :id, ID, null: false
    field :answer_order, Integer, null: true, camelize: false
    field :answer, String, null: true
    field :element_order, Integer, null: true, camelize: false
    field :element, String, null: true
    field :created_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the element was created"
    field :updated_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the element was last updated"
    field :trigger_question, TriggerQuestionType, null: false, camelize: false, description: "The associated trigger question"
  end
end
