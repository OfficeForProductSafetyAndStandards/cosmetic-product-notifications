module Types
  class ImageUploadType < Types::BaseObject
    field :id, ID, null: false
    field :filename, String, null: false, description: "The name of the uploaded file"
    field :created_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the image was uploaded"
    field :updated_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the image upload was last updated"
    field :notification_id, ID, null: false, camelize: false, description: "The ID of the associated notification"
    field :notification, NotificationType, null: false, description: "The associated notification, including its details"
  end
end
