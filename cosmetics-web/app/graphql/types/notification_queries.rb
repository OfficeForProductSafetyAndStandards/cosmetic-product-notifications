module Types
  module NotificationQueries
    extend ActiveSupport::Concern

    included do
      # Query for retrieving a specific notification by its ID
      field :notification, NotificationType, null: true, description: <<~DESC do
        Retrieve a specific notification by its ID.

        Example Query:
        ```
        query {
          notification(id: 1) {
            id
            product_name
            state
            created_at
            updated_at
            import_country
            responsible_person_id
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
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the notification to retrieve"
      end

      # Add cursor-based pagination for notifications with a maximum limit of 100 records per page
      field :notifications, NotificationType.connection_type, null: true, camelize: false, description: <<~DESC
        Retrieve a paginated list of notifications with a maximum of 100 records per page.

        Example Query:
        ```
        query {
          notifications(first: 10, after: "<cursor>") {
            edges {
              node {
                id
                product_name
                state
                created_at
                updated_at
                import_country
                responsible_person_id
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

    # Method to return a specific notification by ID
    def notification(id:)
      Notification.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find notification with 'id'=#{id}"
    end

    # Method to return all notifications with pagination support and a max limit of 100 records
    def notifications(first: nil, last: nil, after: nil, before: nil)
      max_limit = 100
      _after = after
      _before = before

      first = first ? [first, max_limit].min : nil
      last = last ? [last, max_limit].min : nil

      Notification.limit(first || last)
    end
  end
end
