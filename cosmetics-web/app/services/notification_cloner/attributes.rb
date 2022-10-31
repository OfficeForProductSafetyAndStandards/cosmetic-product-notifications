module NotificationCloner
  module Attributes
    NOTIFICATION = [
      :product_name,
      :import_country,
      :responsible_person_id,
      :shades,
      :industry_reference,
      :under_three_years,
      :still_on_the_market,
      :components_are_mixed,
      :ph_min_value,
      :ph_max_value,
      :routing_questions_answers,
      #      :state,
      #      :reference_number,
      #      :cpnp_reference,
      #      :cpnp_notification_date,
      #      :was_notified_before_eu_exit, # default false
      #      :notification_complete_at,
      #      :csv_cache,
      #      :deleted_at,
      #      :previous_state
    ].freeze

    COMPONENT = [
      # :state,
      :shades,
      :notification_type,
      :frame_formulation,
      :sub_sub_category,
      :name,
      :physical_form,
      :special_applicator,
      :acute_poisoning_info,
      :other_special_applicator,
      :contains_poisonous_ingredients,
      :minimum_ph,
      :maximum_ph,
      :ph,
      :exposure_condition,
      :exposure_routes,
      :routing_questions_answers,
      :category,
      :unit,
    ].freeze
    NANOMATERIAL = [
      :inci_name,
      :inn_name,
      :iupac_name,
      :xan_name,
      :cas_number,
      :ec_number,
      :einecs_number,
      :elincs_number,
      :purposes,
      :confirm_usage,
      :nanomaterial_notification_id,
      #  :confirm_restrictions,
    ].freeze
    INGREDIENT = %i[
      inci_name
      cas_number
      exact_concentration
      range_concentration
      poisonous
    ].freeze

    CMR = %i[
      name
      cas_number
      ec_number
    ].freeze
  end
end
