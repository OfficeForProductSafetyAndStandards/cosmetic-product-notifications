namespace :one_off do
  namespace :range_concentration do
    desc "Migrate range_concentration to minimum / maximimum concentration"
    # This task should only be run once, but there are no side effects of
    # running it multiple times
    task migrate: :environment do
      Ingredient
        .where.not(range_concentration: nil)
        .where(minimum_concentration: nil).find_each do |ingredient|
        p "Migrating: #{ingredient.inci_name} - #{ingredient.range_concentration}"

        parsed_range = ingredient_concentration_range(ingredient.range_concentration)
        ingredient.minimum_concentration = parsed_range.above || 0
        ingredient.maximum_concentration = parsed_range.upto

        p "To: #{ingredient.minimum_concentration} - #{ingredient.maximum_concentration}"
        # with a range_concentration `less_than_01_percent`, the `above` is null,
        # as we ensure there is a default value of 0
        ingredient.save(validate: false)
      end
    end
  end
end

# copied from IngredientHelper
def ingredient_concentration_range(range)
  range_klass = Struct.new(:above, :upto)
  return range_klass.new(nil, nil) if range.blank?

  above, upto = range.gsub("greater_than_", "") # "greater_than_01_less_than_1_percent" => "01_less_than_1_percent"
                     .gsub("_percent", "") # => "01_less_than_1"
                     .split(/_?less_than_/) # => ["01", "1"]
                     .map { |n| n[0] == "0" ? n.insert(1, ".") : n } # => ["0.1", "1"]
                     .map { |n| n.remove(/[^\d.]/) } # Removes any non digit/dot char
                     .map(&:presence) # Converts ["", "0.1"] to [nil, "1"]
  range_klass.new(above || 0, upto)
end
