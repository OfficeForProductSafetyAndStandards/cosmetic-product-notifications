module Types
  class NanoMaterialType < Types::BaseObject
    field :id, ID, null: false
    field :created_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the nano material was created"
    field :updated_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the nano material was last updated"
    field :notification_id, ID, null: true, camelize: false
    field :notification, NotificationType, null: false, description: "The associated notification, including its details"
    field :notification_type, String, null: true, camelize: false
    field :inci_name, String, null: true, camelize: false
    field :inn_name, String, null: true, camelize: false
    field :iupac_name, String, null: true, camelize: false
    field :xan_name, String, null: true, camelize: false
    field :cas_number, String, null: true, camelize: false
    field :ec_number, String, null: true, camelize: false
    field :einecs_number, String, null: true, camelize: false
    field :elincs_number, String, null: true, camelize: false
    field :purposes, [String], null: true, camelize: false
    field :confirm_toxicology_notified, String, null: true, camelize: false
    field :confirm_usage, String, null: true, camelize: false
    field :confirm_restrictions, String, null: true, camelize: false
    field :nanomaterial_notification_id, ID, null: true, camelize: false
    field :nanomaterial_notification, NanomaterialNotificationType, null: true, camelize: false, description: "The associated nanomaterial notification"
  end
end
