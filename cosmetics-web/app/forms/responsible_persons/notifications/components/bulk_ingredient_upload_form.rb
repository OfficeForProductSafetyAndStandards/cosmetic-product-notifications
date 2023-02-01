require "csv"

module ResponsiblePersons::Notifications::Components
  class BulkIngredientUploadForm < Form
    class IngredientCanNotBeSavedError < ArgumentError; end

    attribute :file
    attribute :component

    validate :file_is_csv_file_validation
    validate :correct_ingredients_validation

    def prepare_ingredients
      return if @ingredients.present?

      @ingredients = []
      @lines_with_errors = []

      @csv_data&.each_with_index do |row, i|
        name, concentration, cas, poisonous = *row
        ingredient = row_to_ingredient(name, concentration, cas, poisonous)
        unless ingredient.valid?
          @lines_with_errors << i + 1
        end
        @ingredients << ingredient
      end
    end

    def save_ingredients
      return unless valid?

      # Despite validations above, there might be rare case when ingredient can not be saved, eg:
      # * there will be duplicated ingredient in the file
      # * between validation and creation ingredient will be created (very rare edge case)
      # * difference between ingredient form and model validations
      ActiveRecord::Base.transaction do
        @ingredients.each_with_index do |ingredient, i|
          result = ingredient.save

          if result.nil? || !result.persisted?
            raise IngredientCanNotBeSavedError, "The file cound not be uploaded because of errors in line #{i + 1}"
          end
        end
      end
    rescue IngredientCanNotBeSavedError
      nil
    end

  private

    def file_is_csv_file_validation
      parse_csv_file
    rescue CSV::MalformedCSVError, ArgumentError
      errors.add(:file)
    end

    def parse_csv_file
      @csv_data ||= CSV.parse(file&.tempfile)
    end

    def correct_ingredients_validation
      prepare_ingredients

      if @lines_with_errors.present?
        if @lines_with_errors.count == 1
          errors.add(:file, "The file could not be uploaded because of error in line #{@lines_with_errors.first}")
        else
          errors.add(:file, "The file could not be uploaded because of errors in lines: #{@lines_with_errors.join(',')}")
        end
      end
    end

    def row_to_ingredient(name, concentration, cas, poisonous)
      ingredient = ResponsiblePersons::Notifications::IngredientConcentrationForm.new(
        name:, cas_number: cas, poisonous: poisonous?(poisonous),
      )
      if component.exact? # || poisonous
        ingredient.type = ResponsiblePersons::Notifications::IngredientConcentrationForm::EXACT
        ingredient.exact_concentration = concentration
      elsif component.predefined?
        ingredient.type = ResponsiblePersons::Notifications::IngredientConcentrationForm::EXACT
        ingredient.exact_concentration = concentration.to_f
        ingredient.poisonous = true
      end
      ingredient.component = component
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
end
