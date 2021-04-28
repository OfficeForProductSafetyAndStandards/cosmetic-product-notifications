module ComponentBuildHelper
  def cmr_errors(component)
    component.cmrs.each_with_index.flat_map { |cmr, index| cmr.errors.map { |error| { text: error.message, href: "#component_cmrs_attributes_#{index}_#{error.attribute}" } } } +
      component.errors.reject { |_error| attribute.to_s.include? "cmrs." }.map { |error| { text: error.message, href: "#component_cmrs_attributes_0_name" } }
  end

  def previous_wizard_path
    previous_step = get_previous_step
    notification = @component.notification

    if step == :add_component_name
      responsible_person_notification_build_path(notification.responsible_person, notification, :add_new_component)
    elsif step == :number_of_shades && !notification.is_multicomponent?
      responsible_person_notification_build_path(notification.responsible_person, notification, :add_product_image)
    elsif step == :select_category && @category.present?
      wizard_path(:select_category, category: Component.get_parent_category(@category))
    elsif step == :select_category && @component&.nano_material.present?
      last_nanoelement = @component.nano_material.nano_elements.last
      nanoelement_step = last_nanoelement.standard? ? :confirm_usage : :when_products_containing_nanomaterial_can_be_placed_on_market
      responsible_person_notification_component_nanomaterial_build_path(notification.responsible_person, notification, @component, last_nanoelement, nanoelement_step)
    elsif step == :select_formulation_type
      wizard_path(:select_category, category: @component.sub_category)
    elsif step == :upload_formulation && @component.predefined?
      wizard_path(:contains_poisonous_ingredients)
    elsif previous_step.present?
      responsible_person_notification_component_build_path(notification.responsible_person, notification, @component, previous_step)
    else
      super
    end
  end

  def finish_wizard_path
    # This should be new_responsible_person_notification_component_trigger_question_path, but the anti-dandruff questions are due to be removed separately
    responsible_person_notification_component_trigger_question_path(@component.notification.responsible_person, @component.notification, @component, :select_ph_range)
  end
end
