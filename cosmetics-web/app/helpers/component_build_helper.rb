module ComponentBuildHelper
  def cmr_errors(component)
    component.cmrs.each_with_index.flat_map { |cmr, index| cmr.errors.reject { |error| error.type == :neither }.map { |error| { text: error.message, href: "#component_cmrs_attributes_#{index}_#{error.attribute}" } } } +
      component.errors.reject { |error| error.attribute.to_s.include? "cmrs." }.map { |error| { text: error.message, href: "#component_cmrs_attributes_0_name" } }
  end

  def ingredient_errors(component)
    component.ingredients.each_with_index.flat_map do |ingredient, index|
      ingredient.errors.map do |error|
        ingredient_error(error, index)
      end
    end
  end

  def ingredient_error(error, index)
    error_attribute = error.attribute
    error_attribute = :poisonous_true if error_attribute == :poisonous
    error_attribute = :used_for_multiple_shades_true if error_attribute == :used_for_multiple_shades
    {
      text: error.message,
      href: "#component_ingredients_attributes_#{index}_#{error_attribute}",
    }
  end
end
