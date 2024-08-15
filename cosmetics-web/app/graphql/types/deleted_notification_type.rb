module Types
  class DeletedNotificationType < Types::BaseObject
    field :id, ID, null: true
    field :product_name, String, null: true, camelize: false
    field :state, String, null: true
    field :created_at, Types::CustomDateTimeType, null: true, camelize: false
    field :updated_at, Types::CustomDateTimeType, null: true, camelize: false
    field :import_country, String, null: true, camelize: false
    field :responsible_person_id, ID, null: true, camelize: false
    field :notification_id, ID, null: false, camelize: false, description: "The ID of the associated notification"
    field :notification, NotificationType, null: false, description: "The associated notification, including its details"
    field :reference_number, Integer, null: true, camelize: false
    field :cpnp_reference, String, null: true, camelize: false
    field :shades, String, null: true
    field :industry_reference, String, null: true, camelize: false
    field :cpnp_notification_date, Types::CustomDateTimeType, null: true, camelize: false
    field :was_notified_before_eu_exit, Boolean, null: true, camelize: false
    field :under_three_years, Boolean, null: true, camelize: false
    field :still_on_the_market, Boolean, null: true, camelize: false
    field :components_are_mixed, Boolean, null: true, camelize: false
    field :ph_min_value, Float, null: true, camelize: false
    field :ph_max_value, Float, null: true, camelize: false
    field :notification_complete_at, Types::CustomDateTimeType, null: true, camelize: false
    field :csv_cache, String, null: true, camelize: false
  end
end
