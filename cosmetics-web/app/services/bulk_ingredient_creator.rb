require "csv"

class BulkIngredientCreator
  RANGE_CONCENTRATION_MAPPING = {
    "0-0.1" => "less_than_01_percent",
    "0.1-1" => "greater_than_01_less_than_1_percent",
    "1-5" => "greater_than_1_less_than_5_percent",
    "5-10" => "greater_than_5_less_than_10_percent",
    "10-25" => "greater_than_10_less_than_25_percent",
    "25-50" => "greater_than_25_less_than_50_percent",
    "50-75" => "greater_than_50_less_than_75_percent",
    "75-100" => "greater_than_75_less_than_100_percent",
  }.freeze

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
      @ingredients.each do |ingredient|
        result = ingredient.save

        if result.nil? || !result.persisted?
          raise ArgumentError
        end
      end
    end
  rescue ArgumentError
    nil
  end

  # TODO: rename to success?
  def valid?
    @valid ||= @ingredients.all?(&:persisted?)
  end

private

  # Problem:
  # When parsing an ingredient, we are getting ArgumentError
  def row_to_ingredient(name, concentration, cas, poisonous)
    ingredient = ResponsiblePersons::Notifications::IngredientConcentrationForm.new(
      name:, cas_number: cas, poisonous: poisonous?(poisonous),
    )
    if @component.exact? # || poisonous
      ingredient.type = ResponsiblePersons::Notifications::IngredientConcentrationForm::EXACT
      ingredient.exact_concentration = concentration
    elsif @component.range?
      ingredient.type = ResponsiblePersons::Notifications::IngredientConcentrationForm::RANGE
      ingredient.range_concentration = RANGE_CONCENTRATION_MAPPING[concentration]
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
