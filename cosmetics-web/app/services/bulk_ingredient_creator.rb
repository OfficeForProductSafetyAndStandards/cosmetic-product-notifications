require "csv"

class BulkIngredientCreator
  # rubocop:disable Style/MissingRespondToMissing
  ParsedEntry = Struct.new(:line, :ingredient, :line_number) do
    # TODO: weird stuff!
    def save
      model = ingredient.save
      if model
        self.ingredient = model
      end
    end

    def method_missing(*args)
      ingredient.send(*args)
    end
  end
  # rubocop:enable Style/MissingRespondToMissing

  attr_reader :ingredients

  def initialize(csv_data, component)
    @csv_data = csv_data
    @ingredients = []
    @component = component
  end

  def create
    CSV.parse(@csv_data).each_with_index do |row, i|
      name, concentration, cas, poisonous = *row
      ingredient = row_to_ingredient(name, concentration, cas, poisonous)
      @ingredients << ParsedEntry.new(row.join(","), ingredient, i + 1)
    end
    ActiveRecord::Base.transaction do
      @ingredients.each(&:save)
    end
  end

  # TODO: rename to success?
  def valid?
    @valid ||= @ingredients.all?(&:persisted?)
  end

private

  def row_to_ingredient(name, concentration, cas, poisonous)
    ingredient = ResponsiblePersons::Notifications::IngredientConcentrationForm.new(
      name:, cas_number: cas, poisonous: poisonous?(poisonous),
    )
    if @component.exact? # || poisonous
      ingredient.type = ResponsiblePersons::Notifications::IngredientConcentrationForm::EXACT
      ingredient.exact_concentration = concentration.to_f
    elsif @component.range?
      ingredient.type = ResponsiblePersons::Notifications::IngredientConcentrationForm::RANGE
      ingredient.range_concentration = concentration
    elsif @component.predefined?
      ingredient.type = ResponsiblePersons::Notifications::IngredientConcentrationForm::EXACT
      ingredient.exact_concentration = concentration.to_f
      ingredient.poisonous = true
    end
    ingredient.component = @component
    ingredient
  end

  def poisonous?(entry)
    case entry
    when "poisonous"
      true
    when "non_poisonous"
      false
    end
  end
end
