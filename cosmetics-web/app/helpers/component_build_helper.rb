module ComponentBuildHelper
  def cmr_errors(component)
    component.cmrs.each_with_index.flat_map { |cmr, index| cmr.errors.map { |attr, msg| { text: msg, href: "#component_cmrs_attributes_#{index}_#{attr}" } } } +
      component.errors.reject { |attr, _| attr.to_s.include? "cmrs." }.map { |_, msg| { text: msg, href: "#component_cmrs_attributes_0_name" } }
  end

  def previous_wizard_path
    previous_step = get_previous_step
    previous_step = previous_step(previous_step) if skip_step?(previous_step)

    if step == :add_component_name
      responsible_person_notification_build_path(@component.notification.responsible_person, @component.notification, :add_new_component)
    elsif step == :number_of_shades && !@component.notification.is_multicomponent?
      responsible_person_notification_build_path(@component.notification.responsible_person, @component.notification, :single_or_multi_component)
    elsif step == :select_category && @category.present?
      wizard_path(:select_category, category: Component.get_parent_category(@category))
    elsif step == :upload_formulation && @component.predefined?
      wizard_path(:contains_poisonous_ingredients)
    elsif previous_step.present?
      responsible_person_notification_component_build_path(@component.notification.responsible_person, @component.notification, @component, previous_step)
    else
      super
    end
  end

  def finish_wizard_path
    # This should be new_responsible_person_notification_component_trigger_question_path, but the anti-dandruff questions are due to be removed separately
    responsible_person_notification_component_trigger_question_path(@component.notification.responsible_person, @component.notification, @component, :select_ph_range)
  end
end
