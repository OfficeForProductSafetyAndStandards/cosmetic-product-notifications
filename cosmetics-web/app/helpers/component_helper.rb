module ComponentHelper
  def component_special_applicator_name(component)
    component.other_special_applicator.presence || get_special_applicator_name(component.special_applicator)
  end
end
