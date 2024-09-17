module Types
  module NotificationDeleteLogQueries
    extend ActiveSupport::Concern

    included do
      # Query for retrieving a specific notification delete log by its ID
      field :notification_delete_log, NotificationDeleteLogType, null: false, camelize: false, description: <<~DESC do
        Retrieve a specific notification delete log by its ID.

        Example Query:
        ```
        query {
          notification_delete_log(id: 1) {
            id
            submit_user_id
            notification_product_name
            responsible_person_id
            notification_created_at
            notification_updated_at
            cpnp_reference
            created_at
            updated_at
            reference_number
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the notification delete log to retrieve"
      end

      # Add cursor-based pagination for notification_delete_logs with filtering by created_at and updated_at
      field :notification_delete_logs, NotificationDeleteLogType.connection_type, null: false, camelize: false, description: <<~DESC do
        Retrieve a paginated list of notification delete logs with optional filters for created_at and updated_at timestamps.
        A maximum of 100 records can be retrieved per page.

        You can filter by either or both of the `created_after` and `updated_after` fields in the format `YYYY-MM-DD HH:MM`.

        Example Query:
        ```
        query {
          notification_delete_logs(created_after: "2024-08-15T13:00:00Z", updated_after: "2024-08-15T13:00:00Z", first: 10) {
            edges {
              node {
                id
                submit_user_id
                notification_product_name
                responsible_person_id
                notification_created_at
                notification_updated_at
                cpnp_reference
                created_at
                updated_at
                reference_number
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
        argument :created_after, GraphQL::Types::String, required: false, camelize: false, description: "Retrieve notification delete logs created after this date in the format 'YYYY-MM-DD HH:MM'"
        argument :updated_after, GraphQL::Types::String, required: false, camelize: false, description: "Retrieve notification delete logs updated after this date in the format 'YYYY-MM-DD HH:MM'"
       end

      # Query for retrieving the total number of notification delete logs available
      field :total_notification_delete_logs_count, Integer, null: false, camelize: false, description: <<~DESC do
        Retrieve the total number of notification delete logs available.

        Example Query:
        ```
        query {
          total_notification_delete_logs_count
        }
        ```
      DESC
      end
    end

    # Method to return a specific notification delete log by ID
    def notification_delete_log(id:)
      NotificationDeleteLog.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find notification_delete_log with 'id' #{id}"
    rescue StandardError => e
      raise Errors::SimpleError, "An error occurred: #{e.message}"
    end

    # Method to return notification delete logs with optional filters for created_at and updated_at, along with pagination support
    def notification_delete_logs(created_after: nil, updated_after: nil, first: nil, last: nil, after: nil, before: nil)
      max_limit = 100

      first = validate_limit(first, max_limit)
      last = validate_limit(last, max_limit)

      scope = NotificationDeleteLog.all

      # Apply filters for created_at and updated_at
      scope = scope.where("created_at >= ?", Time.zone.parse(created_after).utc) if created_after.present?
      scope = scope.where("updated_at >= ?", Time.zone.parse(updated_after).utc) if updated_after.present?

      scope = apply_pagination(scope, first: first, last: last, after: after, before: before)

      scope.limit(first || last)
    end

    # Method to return the total number of notification delete logs available
    def total_notification_delete_logs_count
      NotificationDeleteLog.count
    end

    private

      # Validate the pagination limit, ensuring it does not exceed max_limit
      def validate_limit(limit, max_limit)
        return nil if limit.nil?
        [limit, max_limit].min
      end

      # Pagination logic with error handling for invalid cursors
      def apply_pagination(scope, first:, last:, after: nil, before: nil)
        return scope if first.nil? && last.nil? # No pagination if both are nil

        if after.present?
          decoded_cursor = safe_decode_cursor(after)
          scope = scope.where('id > ?', decoded_cursor)
        end

        if before.present?
          decoded_cursor = safe_decode_cursor(before)
          scope = scope.where('id < ?', decoded_cursor)
        end

        scope = scope.order(id: :asc) if first
        scope = scope.order(id: :desc) if last

        scope
      end

      # Decode cursor safely, handling errors if cursor is invalid
      def safe_decode_cursor(cursor)
        Base64.decode64(cursor)
      rescue ArgumentError
        raise Errors::SimpleError, "Invalid cursor format"
      end
  end
end
