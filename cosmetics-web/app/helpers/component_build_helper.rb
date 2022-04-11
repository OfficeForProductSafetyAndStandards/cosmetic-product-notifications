module ComponentBuildHelper
  def cmr_errors(component)
    component.cmrs.each_with_index.flat_map { |cmr, index| cmr.errors.map { |error| { text: error.message, href: "#component_cmrs_attributes_#{index}_#{error.attribute}" } } } +
      component.errors.reject { |error| error.attribute.to_s.include? "cmrs." }.map { |error| { text: error.message, href: "#component_cmrs_attributes_0_name" } }
  end
end
