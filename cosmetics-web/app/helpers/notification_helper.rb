module NotificationHelper
  def component_nano_materials_names(component)
    component.nano_materials.map(&:display_name)
  end
end
