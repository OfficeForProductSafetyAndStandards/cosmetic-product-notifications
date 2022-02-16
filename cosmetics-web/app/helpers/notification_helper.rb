module NotificationHelper
  def component_nano_materials_names(component)
    component.nano_materials.map(&:nano_elements).flatten.map(&:display_name)
  end
end
