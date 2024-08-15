module Types
  module NotificationDeleteLogQueries
    extend ActiveSupport::Concern

    included do
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

      field :notification_delete_logs, [NotificationDeleteLogType], null: false, camelize: false, description: <<~DESC
        Retrieve a list of all notification delete logs.

        Example Query:
        ```
        query {
          notification_delete_logs {
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
    end

    def notification_delete_log(id:)
      NotificationDeleteLog.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find NotificationDeleteLog with 'id'=#{id}"
    end

    def notification_delete_logs
      NotificationDeleteLog.all
    end
  end
end
