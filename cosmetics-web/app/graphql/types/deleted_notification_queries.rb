module Types
  module DeletedNotificationQueries
    extend ActiveSupport::Concern

    included do
      # Query for retrieving a specific deleted notification by its ID
      field :deleted_notification, DeletedNotificationType, null: true, camelize: false, description: <<~DESC do
        Retrieve a specific deleted notification by its ID.

        Example Query:
        ```
        query {
          deleted_notification(id: 1) {
            id
            product_name
            state
            created_at
            updated_at
            import_country
            responsible_person_id
            notification_id
            reference_number
            cpnp_reference
            shades
            industry_reference
            cpnp_notification_date
            was_notified_before_eu_exit
            under_three_years
            still_on_the_market
            components_are_mixed
            ph_min_value
            ph_max_value
            notification_complete_at
            csv_cache
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the deleted notification to retrieve"
      end

      # Add cursor-based pagination for deleted_notifications
      field :deleted_notifications, DeletedNotificationType.connection_type, null: true, camelize: false, description: <<~DESC
        Retrieve a paginated list of deleted notifications.

        Example Query:
        ```
        query {
          deleted_notifications(first: 10, after: "<cursor>") {
            edges {
              node {
                id
                product_name
                state
                created_at
                updated_at
                import_country
                responsible_person_id
                notification_id
                reference_number
                cpnp_reference
                shades
                industry_reference
                cpnp_notification_date
                was_notified_before_eu_exit
                under_three_years
                still_on_the_market
                components_are_mixed
                ph_min_value
                ph_max_value
                notification_complete_at
                csv_cache
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

    # Method to return a specific deleted notification by ID
    def deleted_notification(id:)
      DeletedNotification.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find deleted_notification with 'id'=#{id}"
    end

    # Method to return all deleted notifications with pagination support and a max limit of 100 records
    def deleted_notifications(first: nil, last: nil, after: nil, before: nil)
      max_limit = 100
      _after = after
      _before = before

      first = first ? [first, max_limit].min : nil
      last = last ? [last, max_limit].min : nil

      DeletedNotification.limit(first || last)
    end
  end
end
