module Types
  class CmrType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: true
    field :cas_number, String, null: true, camelize: false
    field :ec_number, String, null: true, camelize: false
    field :created_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the CMR was created"
    field :updated_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the CMR was last updated"
    field :component_id, ID, null: true, camelize: false
    field :component, ComponentType, null: true, description: "The associated component"
  end
end
