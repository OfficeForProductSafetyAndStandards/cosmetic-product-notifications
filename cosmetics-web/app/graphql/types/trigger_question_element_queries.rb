module Types
  module TriggerQuestionElementQueries
    extend ActiveSupport::Concern

    included do
      field :trigger_question_element, TriggerQuestionElementType, null: false, camelize: false, description: <<~DESC do
        Retrieve a specific trigger question element by its ID.

        Example Query:
        ```
        query {
          trigger_question_element(id: 1) {
            id
            answer_order
            answer
            element_order
            element
            created_at
            updated_at
            trigger_question {
              id
              question
            }
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the trigger question element to retrieve"
      end

      field :trigger_question_elements, [TriggerQuestionElementType], null: false, camelize: false, description: <<~DESC
        Retrieve a list of all trigger question elements.

        Example Query:
        ```
        query {
          trigger_question_elements {
            id
            answer_order
            answer
            element_order
            element
            created_at
            updated_at
            trigger_question {
              id
              question
            }
          }
        }
        ```
      DESC
    end

    def trigger_question_element(id:)
      TriggerQuestionElement.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find TriggerQuestionElement with 'id'=#{id}"
    end

    def trigger_question_elements
      TriggerQuestionElement.all
    end
  end
end
