module Types
  module NanomaterialNotificationQueries
    extend ActiveSupport::Concern

    included do
      # Query for retrieving a specific nanomaterial notification by its ID
      field :nanomaterial_notification, NanomaterialNotificationType, null: false, camelize: false, description: <<~DESC do
        Retrieve a specific nanomaterial notification by its ID.

        Example Query:
        ```
        query {
          nanomaterial_notification(id: 1) {
            id
            name
            created_at
            updated_at
            responsible_person_id
            user_id
            eu_notified
            notified_to_eu_on
            submitted_at
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the nanomaterial notification to retrieve"
      end

      # Add cursor-based pagination for nanomaterial_notifications
      field :nanomaterial_notifications, NanomaterialNotificationType.connection_type, null: false, camelize: false, description: <<~DESC
        Retrieve a paginated list of nanomaterial notifications.

        Example Query:
        ```
        query {
          nanomaterial_notifications(first: 10, after: "<cursor>") {
            edges {
              node {
                id
                name
                created_at
                updated_at
                responsible_person_id
                user_id
                eu_notified
                notified_to_eu_on
                submitted_at
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

      field :total_nanomaterial_notifications_count, Integer, null: false, camelize: false, description: <<~DESC
        Retrieve the total number of nanomaterial_notifications available.

        Example Query:
        ```
        query {
          total_nanomaterial_notifications_count
        }
        ```
      DESC
    end

    # Method to return a specific nanomaterial notification by ID
    def nanomaterial_notification(id:)
      NanomaterialNotification.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find nanomaterial_notification with 'id'=#{id}"
    end

    # Method to return all nanomaterial notifications with pagination support and a max limit of 100 records
    def nanomaterial_notifications(first: nil, last: nil, after: nil, before: nil)
      max_limit = 100
      _after = after
      _before = before

      first = first ? [first, max_limit].min : nil
      last = last ? [last, max_limit].min : nil

      NanomaterialNotification.limit(first || last)
    end

    def total_nanomaterial_notifications_count
      NanomaterialNotification.count
    end
  end
end
