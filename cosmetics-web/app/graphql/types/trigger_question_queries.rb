module Types
  module TriggerQuestionQueries
    extend ActiveSupport::Concern

    included do
      field :trigger_question, TriggerQuestionType, null: false, camelize: false, description: <<~DESC do
        Retrieve a specific trigger question by its ID.

        Example Query:
        ```
        query {
          trigger_question(id: 1) {
            id
            question
            applicable
            created_at
            updated_at
            component {
              id
              name
            }
            trigger_question_elements {
              id
              answer_order
              answer
              element_order
              element
            }
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the trigger question to retrieve"
      end

      field :trigger_questions, [TriggerQuestionType], null: false, camelize: false, description: <<~DESC
        Retrieve a list of all trigger questions.

        Example Query:
        ```
        query {
          trigger_questions {
            id
            question
            applicable
            created_at
            updated_at
            component {
              id
              name
            }
            trigger_question_elements {
              id
              answer_order
              answer
              element_order
              element
            }
          }
        }
        ```
      DESC
    end

    def trigger_question(id:)
      TriggerQuestion.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find TriggerQuestion with 'id'=#{id}"
    end

    def trigger_questions
      TriggerQuestion.all
    end
  end
end
