module Types
  module NanomaterialNotificationQueries
    extend ActiveSupport::Concern

    included do
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

      field :nanomaterial_notifications, [NanomaterialNotificationType], null: false, camelize: false, description: <<~DESC
        Retrieve a list of all nanomaterial notifications.

        Example Query:
        ```
        query {
          nanomaterial_notifications {
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
    end

    def nanomaterial_notification(id:)
      NanomaterialNotification.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find nanomaterial_notification with 'id'=#{id}"
    end

    def nanomaterial_notifications
      NanomaterialNotification.all
    end
  end
end
