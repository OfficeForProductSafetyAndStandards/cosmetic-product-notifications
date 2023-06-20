require "csv"

module ResponsiblePersons::Notifications::Components
  class BulkIngredientUploadForm < Form
    class IngredientCanNotBeSavedError < ArgumentError; end
    MAX_FILE_SIZE = 15 * 1000

    attribute :file
    attribute :component
    attribute :current_user

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
      errors.add(:file, "The file has invalid characters. Please check and try again")
      false
    end

    def save_ingredients
      # Despite the validations above, there might be rare cases when ingredients cannot be saved, eg:
      # * there is a duplicate ingredient in the file
      # * an ingredient is created outside this process between validation and creation (very rare edge case)
      # * difference between ingredient form and model validations
      # * internal ActiveRecord issue
      ActiveRecord::Base.transaction do
        component.ingredients.delete_all

        return false unless valid?

        @ingredients.each_with_index do |ingredient, i|
          ingredient.save
          unless ingredient.persisted?
            raise IngredientCanNotBeSavedError, "The file has an error in row #{i + 1}: #{ingredient.errors.full_messages.join(', ')}"
          end
        end
      end
    rescue ActiveRecord::StatementInvalid
      errors.add(:file, "The file has invalid characters. Please check and try again")
      false
    rescue IngredientCanNotBeSavedError => e
      errors.add(:file, e.message)
      false
    end

  private

    def file_size_validation
      if file_too_large?
        errors.add(:file, "The file must be smaller than 15KB")
      end
    end

    def file_is_csv_file_validation
      return if file_too_large?

      parse_csv_file
    rescue CSV::MalformedCSVError, ArgumentError
      errors.add(:file)
    end

    def parse_csv_file
      if component.range?
        headers = %i[inci_name minimum_concentration maximum_concentration exact_concentration cas_number poisonous]
      else
        headers = %i[inci_name concentration cas_number poisonous]
        headers << :multiple_shades if multiple_shades?
      end

      @csv_data ||= CSV.parse(file&.tempfile, headers:, skip_blanks: true)
    end

    def correct_ingredients_validation
      prepare_ingredients

      if @error_rows.count == 1
        errors.add(:file, "The file has an error in row: #{@error_rows.first}")
      elsif @error_rows.count > 1
        errors.add(:file, "The file has an error in rows: #{@error_rows.join(',')}")
      end
    end

    def header_missing_validation
      return if csv_header.blank?

      if row_to_ingredient(**csv_header.to_h)&.valid?
        errors.add(:file, "The supplied header row must be included in the file")
      end
    end

    def prepare_ingredients
      return if @ingredients.present?

      @ingredients = []
      @error_rows = []

      return if duplicated_ingredients_in_file?

      ingredients_from_csv&.each_with_index do |row, i|
        next if row.to_h.values.compact.empty?

        ingredient = row_to_ingredient(**row.to_h)
        unless ingredient&.valid?
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

    def multiple_shades?
      component.shades.present?
    end

    def row_to_ingredient(opts)
      opts = opts.transform_values { |v| v.to_s.strip.gsub(/[[:^ascii:]]/, "") }

      component.range? ? range_row_to_ingredient(**opts) : exact_row_to_ingredient(**opts)
    end

    def exact_row_to_ingredient(inci_name:, cas_number:, concentration:, poisonous:, multiple_shades: nil, **unwanted)
      return if unwanted.present?
      return if multiple_shades.present? && !multiple_shades?

      ingredient = Ingredient.new(
        component:, inci_name:, cas_number:, poisonous: cast_boolean(poisonous), used_for_multiple_shades: cast_boolean(multiple_shades),
      )

      if component.exact?
        ingredient.exact_concentration = concentration
      elsif component.predefined?
        ingredient.exact_concentration = concentration.to_f
        ingredient.poisonous = true
      end
      ingredient
    end

    def range_row_to_ingredient(inci_name:, cas_number:, minimum_concentration:, maximum_concentration:, exact_concentration:, poisonous:, **_unwanted)
      Ingredient.new(
        component:, inci_name:, cas_number:, poisonous: cast_boolean(poisonous),
        minimum_concentration:, maximum_concentration:, exact_concentration:
      )
    end

    def duplicated_ingredients_in_file?
      names = []
      ingredients_from_csv&.each_with_index do |row, i|
        name = row[0]
        if names.include? name
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

    def cast_boolean(entry)
      { "TRUE" => true,
        "FALSE" => false,
        "true" => true,
        "false" => false }[entry]
    end
  end
end
