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
    validate :header_missing_validation
    validate :correct_ingredients_validation

    # Original valid is reseting error messages.
    # We have an edge case here where we are adding error messages after
    # validation - during actual ingredient creation
    def valid?
      return false if errors.present?

      super
    rescue ActiveRecord::StatementInvalid
      errors.add(:file, "File has incorrect characters. Please check and try again")
      false
    end

    def save_ingredients
      # Despite validations above, there might be rare case when ingredient can not be saved, eg:
      # * there will be duplicated ingredient in the file
      # * between validation and creation ingredient will be created (very rare edge case)
      # * difference between ingredient form and model validations
      # * internal ActiveRecord issue
      ActiveRecord::Base.transaction do
        component.ingredients.delete_all

        return false unless valid?

        @ingredients.each_with_index do |ingredient, i|
          ingredient.save
          unless ingredient.persisted?
            raise IngredientCanNotBeSavedError, "The file has error in row #{i + 1}: #{ingredient.errors.full_messages.join(', ')}"
          end
        end
      end
    rescue ActiveRecord::StatementInvalid
      errors.add(:file, "File has incorrect characters. Please check and try again")
      false
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
      @csv_data ||= CSV.parse(file&.tempfile, headers: %i[inci_name concentration cas_number poisonous])
    end

    def correct_ingredients_validation
      prepare_ingredients

      if @error_rows.count == 1
        errors.add(:file, "The file has error in row: #{@error_rows.first}")
      elsif @error_rows.count > 1
        errors.add(:file, "The file has error in rows: #{@error_rows.join(',')}")
      end
    end

    def header_missing_validation
      return if csv_header.blank?

      if row_to_ingredient(**csv_header.to_h).valid?
        errors.add(:file, "The supplied header row must be included in the file")
      end
    end

    def prepare_ingredients
      return if @ingredients.present?

      @ingredients = []
      @error_rows = []

      return if duplicated_ingredients_in_file?

      ingredients_from_csv&.each_with_index do |row, i|
        ingredient = row_to_ingredient(**row.to_h)
        unless ingredient.valid?
          @error_rows << i + 2
        end
        @ingredients << ingredient
      end
    end

    def file_is_not_empty_validation
      return if file_too_large?

      if ingredients_from_csv.blank?
        errors.add(:file, :empty)
      end
    end

    def file_too_large?
      file&.tempfile&.size.to_i > MAX_FILE_SIZE
    end

    def row_to_ingredient(inci_name:, cas_number:, concentration:, poisonous:)
      ingredient = Ingredient.new(
        inci_name:, cas_number:, poisonous: poisonous?(poisonous),
      )
      if component.exact?
        ingredient.exact_concentration = concentration
      elsif component.predefined?
        ingredient.exact_concentration = concentration.to_f
        ingredient.poisonous = true
      end
      ingredient.component = component
      ingredient
    end

    def duplicated_ingredients_in_file?
      names = []
      ingredients_from_csv&.each_with_index do |row, i|
        name = row[0]
        if names.include? name
          # errors.add(:file, "The file has error in row #{i + 1}")
          @error_rows << i + 2
          return true
        end
        if name.present?
          names << name
        end
      end
      false
    end

    def csv_header
      return [] if @csv_data.nil?

      @csv_data[0]
    end

    def ingredients_from_csv
      return [] if @csv_data.nil?

      @csv_data[1..]
    end

    def poisonous?(entry)
      { "TRUE" => true,
        "FALSE" => false,
        "true" => true,
        "false" => false }[entry]
    end
  end
end
