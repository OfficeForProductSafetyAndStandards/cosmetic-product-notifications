require "csv"

module ResponsiblePersons::Notifications::Components
  class BulkIngredientUploadForm < Form
    class IngredientCanNotBeSavedError < ArgumentError; end
    MAX_FILE_SIZE = 15 * 1000

    attribute :file
    attribute :component

    validate :file_size_validation
    validate :file_is_csv_file_validation
    validate :file_is_not_empty_validation
    validate :correct_ingredients_validation

    # Original valid is reseting error messages.
    # We have an edge case here where we are adding error messages after
    # validation - during actuall ingredient creation
    def valid?
      return false if errors.present?

      super
    end

    def prepare_ingredients
      return if @ingredients.present?

      @ingredients = []
      @error_messages = []

      @csv_data&.each_with_index do |row, i|
        name, concentration, cas, poisonous = *row
        ingredient = row_to_ingredient(name, concentration, cas, poisonous)
        unless ingredient.valid?
          @error_messages << { line: i + 1, message: ingredient.errors.full_messages.first }
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
          ingredient.save
          unless ingredient.persisted?
            raise IngredientCanNotBeSavedError, "The file cound not be uploaded because of errors in line #{i + 1}: #{ingredient.errors.full_messages.join(', ')}"
          end
        end
      end
    rescue IngredientCanNotBeSavedError => e
      errors.add(:file, e.message)
      false
    end

  private

    def file_size_validation
      if file_too_large?
        errors.add(:file, "The selected file must be smaller than 15KB")
      end
    end

    def file_is_csv_file_validation
      return if file_too_large?

      parse_csv_file
    rescue CSV::MalformedCSVError, ArgumentError
      errors.add(:file)
    end

    def parse_csv_file
      @csv_data ||= CSV.parse(file&.tempfile)
    end

    def correct_ingredients_validation
      prepare_ingredients

      @error_messages.each do |message|
        errors.add(:file, "The file could not be uploaded because of error in line #{message[:line]}: #{message[:message]}")
      end
    end

    def file_is_not_empty_validation
      return if file_too_large?

      if @csv_data.blank?
        errors.add(:file, :empty)
      end
    end

    def file_too_large?
      file&.tempfile&.size.to_i > MAX_FILE_SIZE
    end

    def row_to_ingredient(name, concentration, cas, poisonous)
      ingredient = Ingredient.new(
        inci_name: name, cas_number: cas, poisonous: poisonous?(poisonous),
      )
      if component.exact? # || poisonous
        ingredient.exact_concentration = concentration
      elsif component.predefined?
        ingredient.exact_concentration = concentration.to_f
        ingredient.poisonous = true
      end
      ingredient.component = component
      ingredient
    end

    def poisonous?(entry)
      { "TRUE" => true,
        "FALSE" => false,
        "true" => true,
        "false" => false }[entry]
    end
  end
end
