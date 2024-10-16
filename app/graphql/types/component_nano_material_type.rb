module Types
  class ComponentNanoMaterialType < Types::BaseObject
    field :id, ID, null: false
    field :component_id, ID, null: true, camelize: false
    field :component, ComponentType, null: false, description: "The associated component"
    field :nano_material_id, ID, null: false, camelize: false
    field :nano_material, NanoMaterialType, null: false, camelize: false, description: "The associated nano material"
    field :created_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the ComponentNanoMaterial was created"
    field :updated_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the ComponentNanoMaterial was last updated"
  end
end
