module CategoryHelper
  def full_category_display_name(component)
    component.display_root_category + ", " + \
      component.display_sub_category + ", " + \
      component.display_sub_sub_category
  end

  def get_full_category_name(sub_sub_category)
    sub_category = Component.get_parent_category(sub_sub_category.to_sym)
    "#{get_category_name(sub_category)} - #{get_category_name(sub_sub_category)}"
  end

  def get_sub_sub_categories
    parent_of_categories = Component.get_parent_of_categories
    Component.categories.reject { |key| parent_of_categories.has_value?(key.to_sym) }
  end
end
