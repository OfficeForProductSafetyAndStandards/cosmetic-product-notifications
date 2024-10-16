module ComponentHelper
  def component_special_applicator_name(component)
    component.other_special_applicator.presence || get_special_applicator_name(component.special_applicator)
  end

  # The input fields for pH values use virtual attributes
  # to avoid accessibility issues with duplicate field name
  # With these helpers, we convert the field names in errors
  # from, e.g. minimum_ph to lower_than_3_minimum_pth
  def ph_value_error_summary(component)
    error_summary(
      component.errors,
      map_errors: {
        minimum_ph: "component_#{component.ph}_minimum_ph",
        maximum_ph: "component_#{component.ph}_maximum_ph",
      },
    )
  end

  def ph_value_error_message(ph_scope, component, input_field)
    return unless component.ph == ph_scope && component.errors[input_field].present?

    { text: component.errors[input_field].join("<br/>").html_safe }
  end
end
