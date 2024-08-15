module Types
  module DeletedNotificationQueries
    extend ActiveSupport::Concern

    included do
      field :deleted_notifications, [DeletedNotificationType], null: true, camelize: false, description: <<~DESC
        Retrieve a list of deleted notifications.

        Example Query:
        ```
        query {
          deleted_notifications {
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
    end

    def deleted_notifications
      DeletedNotification.all
    end

    def deleted_notification(id:)
      DeletedNotification.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find deleted_notification with 'id'=#{id}"
    end
  end
end
