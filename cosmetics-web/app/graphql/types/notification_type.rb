module Types
  class NotificationType < Types::BaseObject
    field :id, ID, null: true
    field :product_name, String, null: true, camelize: false
    field :state, String, null: true
    field :created_at, Types::CustomDateTimeType, null: true, camelize: false
    field :updated_at, Types::CustomDateTimeType, null: true, camelize: false
    field :import_country, String, null: true, camelize: false
    field :responsible_person_id, ID, null: true, camelize: false
    field :responsible_person, ResponsiblePersonType, null: true, camelize: false, description: "The associated responsible person"
    field :reference_number, Integer, null: true, camelize: false
    field :cpnp_reference, String, null: true, camelize: false
    field :shades, String, null: true
    field :cpnp_notification_date, Types::CustomDateTimeType, null: true, camelize: false
    field :industry_reference, String, null: true, camelize: false
    field :under_three_years, Boolean, null: true, camelize: false
    field :still_on_the_market, Boolean, null: true, camelize: false
    field :was_notified_before_eu_exit, Boolean, null: true, camelize: false
    field :components_are_mixed, Boolean, null: true, camelize: false
    field :ph_min_value, Float, null: true, camelize: false
    field :ph_max_value, Float, null: true, camelize: false
    field :notification_complete_at, Types::CustomDateTimeType, null: true, camelize: false
    field :csv_cache, String, null: true, camelize: false
    field :deleted_at, Types::CustomDateTimeType, null: true, camelize: false
    field :routing_questions_answers, GraphQL::Types::JSON, null: true, camelize: false
    field :previous_state, String, null: true, camelize: false
    field :source_notification_id, Integer, null: true, camelize: false
    field :archive_reason, String, null: true, camelize: false
  end
end
