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

      # Add cursor-based pagination for notification_delete_logs
      field :notification_delete_logs, NotificationDeleteLogType.connection_type, null: false, camelize: false, description: <<~DESC
        Retrieve a paginated list of notification delete logs.

        Example Query:
        ```
        query {
          notification_delete_logs(first: 10, after: "<cursor>") {
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
    end

    # Method to return a specific notification delete log by ID
    def notification_delete_log(id:)
      NotificationDeleteLog.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find notification_delete_log with 'id'=#{id}"
    end

    # Method to return all notification delete logs with pagination support and a max limit of 100 records
    def notification_delete_logs(first: nil, last: nil, after: nil, before: nil)
      max_limit = 100
      _after = after
      _before = before

      first = first ? [first, max_limit].min : nil
      last = last ? [last, max_limit].min : nil

      NotificationDeleteLog.limit(first || last)
    end
  end
end
