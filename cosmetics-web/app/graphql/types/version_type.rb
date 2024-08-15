module Types
  class VersionType < Types::BaseObject
    field :id, ID, null: false
    field :item_type, String, null: false, camelize: false, description: "The type of the item that was changed"
    field :item_id, ID, null: false, camelize: false, description: "The ID of the item that was changed"
    field :event, String, null: false, description: "The type of event that occurred (e.g., create, update, destroy)"
    field :whodunnit, String, null: true, description: "The ID of the user who made the change"
    field :object, GraphQL::Types::JSON, null: true, description: "The object as it was before the change"
    field :object_changes, GraphQL::Types::JSON, null: true, camelize: false, description: "The changes that were made to the object"
    field :created_at, Types::CustomDateTimeType, null: true, camelize: false, description: "The date and time when the version was created"
  end
end
