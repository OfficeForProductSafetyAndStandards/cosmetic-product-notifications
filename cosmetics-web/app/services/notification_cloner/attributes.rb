module NotificationCloner
  module Attributes
    NOTIFICATION = %i[
      import_country
      responsible_person_id
      shades
      industry_reference
      under_three_years
      still_on_the_market
      components_are_mixed
      ph_min_value
      ph_max_value
      routing_questions_answers
    ].freeze

    COMPONENT = %i[
      shades
      notification_type
      frame_formulation
      sub_sub_category
      name
      physical_form
      special_applicator
      acute_poisoning_info
      other_special_applicator
      contains_poisonous_ingredients
      minimum_ph
      maximum_ph
      ph
      exposure_condition
      exposure_routes
      routing_questions_answers
      category
      unit
    ].freeze

    NANOMATERIAL = %i[
      inci_name
      inn_name
      iupac_name
      xan_name
      cas_number
      ec_number
      einecs_number
      elincs_number
      purposes
      confirm_usage
      nanomaterial_notification_id
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
