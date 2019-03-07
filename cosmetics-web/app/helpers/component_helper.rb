module ComponentHelper
  include CpnpHelper

  def component_type(component)
    get_notification_type_name(component.notification_type)
  end

  def component_categories(component)
    [get_category_name(component.root_category),
     get_category_name(component.sub_category),
     get_category_name(component.sub_sub_category)]* ' - '
  end

  def component_frame_formulation(component)
    get_frame_formulation_name(component.frame_formulation)
  end
end
