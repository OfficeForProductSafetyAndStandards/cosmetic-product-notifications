module Types
  module TriggerQuestionQueries
    extend ActiveSupport::Concern

    included do
      # Query for retrieving a specific trigger question by its ID
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

      # Add cursor-based pagination for trigger_questions
      field :trigger_questions, TriggerQuestionType.connection_type, null: false, camelize: false, description: <<~DESC
        Retrieve a paginated list of all trigger questions.

        Example Query:
        ```
        query {
          trigger_questions(first: 10, after: "<cursor>") {
            edges {
              node {
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

    # Method to return a specific trigger question by ID
    def trigger_question(id:)
      TriggerQuestion.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find trigger_question with 'id'=#{id}"
    end

    # Method to return all trigger questions with pagination support and a max limit of 100 records
    def trigger_questions(first: nil, last: nil, after: nil, before: nil)
      max_limit = 100
      _after = after
      _before = before

      first = first ? [first, max_limit].min : nil
      last = last ? [last, max_limit].min : nil

      TriggerQuestion.limit(first || last)
    end
  end
end
