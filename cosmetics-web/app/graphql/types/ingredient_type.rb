module Types
  class IngredientType < Types::BaseObject
    field :id, ID, null: true
    field :inci_name, String, null: true, camelize: false
    field :cas_number, String, null: true, camelize: false
    field :exact_concentration, Float, null: true, camelize: false
    field :range_concentration, String, null: true, camelize: false
    field :poisonous, Boolean, null: true
    field :created_at, Types::CustomDateTimeType, null: true, camelize: false
    field :updated_at, Types::CustomDateTimeType, null: true, camelize: false
    field :component_id, ID, null: true, camelize: false
    field :component, ComponentType, null: false, description: "The associated component"
    field :used_for_multiple_shades, Boolean, null: true, camelize: false
    field :minimum_concentration, Float, null: true, camelize: false
    field :maximum_concentration, Float, null: true, camelize: false
  end
end
