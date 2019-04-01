module CategoryHelper
  def full_category_display_name(component)
    component.display_root_category + ", " + \
      component.display_sub_category + ", " + \
      component.display_sub_sub_category
  end
end
