module Types
  class ComponentType < Types::BaseObject
    field :id, ID, null: true
    field :state, String, null: true
    field :shades, [String], null: true
    field :created_at, Types::CustomDateTimeType, null: true, camelize: false
    field :updated_at, Types::CustomDateTimeType, null: true, camelize: false
    field :notification_id, ID, null: true, camelize: false
    # field :notification, NotificationType, null: false, description: "The associated notification, including its details"
    field :notification_type, String, null: true, camelize: false
    field :frame_formulation, String, null: true, camelize: false
    field :sub_sub_category, String, null: true, camelize: false
    field :name, String, null: true
    field :physical_form, String, null: true, camelize: false
    field :special_applicator, String, null: true, camelize: false
    field :acute_poisoning_info, String, null: true, camelize: false
    field :other_special_applicator, String, null: true, camelize: false
    field :contains_poisonous_ingredients, Boolean, null: true, camelize: false
    field :minimum_ph, Float, null: true, camelize: false
    field :maximum_ph, Float, null: true, camelize: false
    field :ph, String, null: true
    field :exposure_condition, String, null: true, camelize: false
    field :exposure_routes, [String], null: true, camelize: false
    field :routing_questions_answers, GraphQL::Types::JSON, null: true, camelize: false
    field :notification_type_given_as, String, null: true, camelize: false
    # field :ingredients, [Types::IngredientType], null: true, description: "**New!** Example of a new field"
  end
end
