module ComponentBuildHelper
  def cmr_errors(component)
    result = []
    component.cmrs.each_with_index do |cmr, index|
      cmr.errors.each do |attr, msg|
        result.push(text: msg, href: "#component_cmrs_attributes_#{index}_#{attr}")if cmr.errors.any?
      end
    end
    result
  end
end
