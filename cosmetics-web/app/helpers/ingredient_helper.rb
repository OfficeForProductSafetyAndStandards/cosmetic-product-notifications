module IngredientHelper
  # Transforms "greater_than_01_less_than_1_percent" a
  # struct with 'above: 0.1' and 'upto: 1'
  def ingredient_concentration_range(range)
    range_klass = Struct.new(:above, :upto)
    return range_klass.new(nil, nil) if range.blank?

    above, upto = range.gsub("greater_than_", "") # "greater_than_01_less_than_1_percent" => "01_less_than_1_percent"
                       .gsub("_percent", "") # => "01_less_than_1"
                       .split(/_?less_than_/) # => ["01", "1"]
                       .map { |n| n[0] == "0" ? n.insert(1, ".") : n } # => ["0.1", "1"]
                       .map { |n| n.remove(/[^\d.]/) } # Removes any non digit/dot char
                       .map(&:presence) # Converts ["", "0.1"] to [nil, "1"]
    range_klass.new(above, upto)
  end

  def format_exact_ingredients(exact_ingredients)
    exact_ingredients.map do |ingredient|
      { inci_name: ingredient.inci_name, exact_concentration: display_concentration(ingredient.exact_concentration, used_for_multiple_shades: ingredient.used_for_multiple_shades?) }
    end
  end

  def format_range_ingredients(range_ingredients)
    range_ingredients.map do |ingredient|
      { inci_name: ingredient.inci_name, range_concentration: display_concentration_range(ingredient.range_concentration) }
    end
  end

  def csv_file_type(component)
    return "range" if component.range?
    return "exact-with-multiple-shades" if component.shades.present?

    "exact"
  end
end
