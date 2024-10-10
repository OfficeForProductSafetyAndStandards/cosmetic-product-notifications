module Types
  class TriggerQuestionType < Types::BaseObject
    field :id, ID, null: false
    field :question, String, null: false
    field :applicable, Boolean, null: true
    field :created_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the question was created"
    field :updated_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the question was last updated"
    field :component_id, ID, null: true, camelize: false
    field :component, ComponentType, null: false, description: "The associated component"
    field :trigger_question_elements, [TriggerQuestionElementType], null: true, camelize: false, description: "The associated trigger question elements"
  end
end
