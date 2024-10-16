module Types
  class NanomaterialNotificationType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: true
    field :created_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the nanomaterial notification was created"
    field :updated_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the nanomaterial notification was last updated"
    field :responsible_person_id, ID, null: true, camelize: false, description: "The ID of the associated notification"
    field :responsible_person, ResponsiblePersonType, null: false, camelize: false, description: "The associated responsible person"
    field :notification, NotificationType, null: false, description: "The associated notification, including its details"
    field :user_id, String, null: false, camelize: false
    field :user, UserType, null: false, description: "The associated user, including its details"
    field :eu_notified, Boolean, null: true, camelize: false
    field :notified_to_eu_on, Types::CustomDateTimeType, null: true, camelize: false
    field :submitted_at, Types::CustomDateTimeType, null: true, camelize: false
  end
end
