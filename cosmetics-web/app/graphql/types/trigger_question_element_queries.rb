module Types
  module TriggerQuestionElementQueries
    extend ActiveSupport::Concern

    included do
      # Query for retrieving a specific trigger question element by its ID
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

      # Add cursor-based pagination for trigger_question_elements
      field :trigger_question_elements, TriggerQuestionElementType.connection_type, null: false, camelize: false, description: <<~DESC
        Retrieve a paginated list of all trigger question elements.

        Example Query:
        ```
        query {
          trigger_question_elements(first: 10, after: "<cursor>") {
            edges {
              node {
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
              cursor
            }
            pageInfo {
              hasNextPage
              hasPreviousPage
              startCursor
              endCursor
            }
          }
        }
        ```
      DESC
    end

    # Method to return a specific trigger question element by ID
    def trigger_question_element(id:)
      TriggerQuestionElement.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find trigger_question_element with 'id'=#{id}"
    end

    # Method to return all trigger question elements with pagination support and a max limit of 100 records
    def trigger_question_elements(first: nil, last: nil, after: nil, before: nil)
      max_limit = 100
      _after = after
      _before = before

      first = first ? [first, max_limit].min : nil
      last = last ? [last, max_limit].min : nil

      TriggerQuestionElement.limit(first || last)
    end
  end
end
