module Types
  module NotificationQueries
    extend ActiveSupport::Concern

    included do
      field :notifications, [NotificationType], null: true, camelize: false, description: <<~DESC
        Retrieve a list of notifications.

        Example Query:
        ```
        query {
          notifications {
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
    end

    def notifications
      Notification.all
    end

    def notification(id:)
      Notification.find(id)
    end
  end
end
