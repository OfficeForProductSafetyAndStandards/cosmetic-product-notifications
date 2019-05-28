module ComponentBuildHelper
  def cmr_errors(component)
    component.cmrs.each_with_index.flat_map { |cmr, index| cmr.errors.map { |attr, msg| { text: msg, href: "#component_cmrs_attributes_#{index}_#{attr}" } } }
  end
end
