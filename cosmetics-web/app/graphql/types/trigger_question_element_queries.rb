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

      field :trigger_question_elements, TriggerQuestionElementType.connection_type, null: false, camelize: false, description: <<~DESC do
        Retrieve a paginated list of trigger question elements with optional filters for created_at and updated_at timestamps.
        A maximum of 100 records can be retrieved per page.

        You can filter by either or both of the `created_after` and `updated_after` fields in the format `YYYY-MM-DD HH:MM`.

        Example Query:
        ```
        query {
          trigger_question_elements(created_after: "2024-08-15T13:00:00Z", updated_after: "2024-08-15T13:00:00Z", first: 10) {
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
        argument :created_after, GraphQL::Types::String, required: false, camelize: false, description: "Retrieve trigger question elements created after this date in the format 'YYYY-MM-DD HH:MM'"
        argument :updated_after, GraphQL::Types::String, required: false, camelize: false, description: "Retrieve trigger question elements updated after this date in the format 'YYYY-MM-DD HH:MM'"
      end

      field :total_trigger_question_elements_count, Integer, null: false, camelize: false, description: <<~DESC do
        Retrieve the total number of trigger question elements available.

        Example Query:
        ```
        query {
          total_trigger_question_elements_count
        }
        ```
      DESC
      end
    end

    def trigger_question_element(id:)
      TriggerQuestionElement.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find trigger_question_element with 'id' #{id}"
    rescue StandardError => e
      raise Errors::SimpleError, "An error occurred: #{e.message}"
    end

    def trigger_question_elements(created_after: nil, updated_after: nil, first: nil, last: nil, after: nil, before: nil)
      max_limit = 100

      first = validate_limit(first, max_limit)
      last = validate_limit(last, max_limit)

      scope = TriggerQuestionElement.all

      scope = scope.where("created_at >= ?", Time.zone.parse(created_after).utc) if created_after.present?
      scope = scope.where("updated_at >= ?", Time.zone.parse(updated_after).utc) if updated_after.present?

      scope = apply_pagination(scope, first:, last:, after:, before:)

      scope.limit(first || last)
    end

    def total_trigger_question_elements_count
      TriggerQuestionElement.count
    end

  private

    def validate_limit(limit, max_limit)
      return nil if limit.nil?

      [limit, max_limit].min
    end

    def apply_pagination(scope, first:, last:, after: nil, before: nil)
      return scope if first.nil? && last.nil?

      if after.present?
        decoded_cursor = safe_decode_cursor(after)
        scope = scope.where("id > ?", decoded_cursor)
      end

      if before.present?
        decoded_cursor = safe_decode_cursor(before)
        scope = scope.where("id < ?", decoded_cursor)
      end

      scope = scope.order(id: :asc) if first
      scope = scope.order(id: :desc) if last

      scope
    end

    def safe_decode_cursor(cursor)
      Base64.decode64(cursor)
    rescue ArgumentError
      raise Errors::SimpleError, "Invalid cursor format"
    end
  end
end