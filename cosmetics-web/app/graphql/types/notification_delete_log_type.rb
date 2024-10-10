module Types
  class NotificationDeleteLogType < Types::BaseObject
    field :id, ID, null: false
    field :submit_user_id, String, null: true, camelize: false
    field :submit_user, UserType, null: false, description: "The associated user, including its details"
    field :notification_product_name, String, null: true, camelize: false
    field :responsible_person_id, ID, null: true, camelize: false, description: "The ID of the associated notification"
    field :responsible_person, ResponsiblePersonType, null: true, camelize: false, description: "The associated responsible person"
    field :notification_created_at, Types::CustomDateTimeType, null: true, camelize: false
    field :notification_updated_at, Types::CustomDateTimeType, null: true, camelize: false
    field :cpnp_reference, String, null: true, camelize: false
    field :created_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the log was created"
    field :updated_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the log was last updated"
    field :reference_number, Integer, null: true, camelize: false
  end
end
