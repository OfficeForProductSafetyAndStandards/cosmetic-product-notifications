require "csv"

module ResponsiblePersons::Notifications::Components
  class BulkIngredientUploadForm < Form
    class IngredientCanNotBeSavedError < ArgumentError; end

    class IngredientContainsExtraColumnsError < ArgumentError
      attr_reader :line

      def initialize(line)
        @line = line.to_i
        super "The ingredient row contains extra columns"
      end
    end

    MAX_FILE_SIZE = 15 * 1000

    attribute :file
    attribute :component
    attribute :current_user

    validate :file_size_validation
    validate :file_is_csv_file_validation
    validate :file_is_not_empty_validation
    validate :header_missing_validation
    validate :duplicated_ingredients_validation
    validate :correct_ingredients_validation

    def save_ingredients
      # Despite the validations above, there might be rare cases when ingredients cannot be saved, eg:
      # * an ingredient is created outside this process between validation and creation (very rare edge case)
      # * difference between ingredient form and model validations
      ActiveRecord::Base.transaction do
        component.ingredients.delete_all

        return false unless valid?

        @ingredients.each do |ingredient|
          raise IngredientCanNotBeSavedError unless ingredient.save
        end
      end
    rescue ActiveRecord::StatementInvalid
      errors.add(:file, "The selected file must be a valid CSV")
      false
    rescue IngredientCanNotBeSavedError
      errors.add(:file, "The selected file could not be uploaded - try again")
      false
    end

    def error_rows
      @error_rows || {}
    end

  private

    def file_size_validation
      errors.add(:file, "The selected file must be smaller than 15KB") if file_too_large?
    end

    def file_is_csv_file_validation
      return if file_too_large?

      errors.add(:file, "The selected file must be a CSV") && return if file_type_incorrect?

      parse_csv_file
    rescue CSV::MalformedCSVError, ArgumentError
      errors.add(:file, "The selected file must be a valid CSV")
    end

    def file_is_not_empty_validation
      return if file_too_large? || file_type_incorrect?

      errors.add(:file, "The selected file is empty") if ingredients_from_csv.blank?
    end

    def header_missing_validation
      return if csv_header.blank?

      errors.add(:file, "The header row must be included in the selected file") if file_header_incorrect?
    end

    def duplicated_ingredients_validation
      return if file_header_incorrect?

      names = []
      ingredients_from_csv&.each do |row|
        name = row[0]

        return errors.add(:file, "The selected file contains ingredients that are duplicated") if names.include?(name)

        names << name if name.present?
      end
    end

    def correct_ingredients_validation
      return if file_header_incorrect?

      prepare_ingredients

      errors.add(:file, "The selected file could not be uploaded - try again") if @error_rows.present?
    rescue ActiveRecord::StatementInvalid
      errors.add(:file, "The selected file contains invalid characters")
    end

    def file_too_large?
      file&.tempfile&.size.to_i > MAX_FILE_SIZE
    end

    def file_type_incorrect?
      file&.content_type != "text/csv"
    end

    def file_header_incorrect?
      csv_header.to_s.chomp != csv_header_template
    end

    def parse_csv_file
      if component.range?
        headers = %i[inci_name minimum_concentration maximum_concentration exact_concentration cas_number poisonous]
      else
        headers = %i[inci_name concentration cas_number poisonous]
        headers << :multiple_shades if multiple_shades?
      end

      @csv_data ||= CSV.parse(file&.tempfile, headers:)
    end

    def prepare_ingredients
      return if @ingredients.present?

      @ingredients = []
      @error_rows = {}

      ingredients_from_csv&.each_with_index do |row, i|
        # Ignore empty rows
        next if row.to_h.values.compact.empty?

        ingredient = row_to_ingredient(i, **row.to_h)

        @error_rows[i + 2] = replace_error_messages(ingredient&.errors&.messages) unless ingredient&.valid?(:bulk_upload)
        @ingredients << ingredient
      rescue IngredientContainsExtraColumnsError => e
        @error_rows[e.line + 2] = { base: [e.message] }
        next
      end
    end

    def multiple_shades?
      component.shades.present?
    end

    def row_to_ingredient(index, opts)
      # Strip any leading or trailing spaces
      opts = opts.transform_values { |v| v.to_s.strip.gsub(/^\s+|\s+$/, "") }

      component.range? ? range_row_to_ingredient(index, **opts) : exact_row_to_ingredient(index, **opts)
    end

    def exact_row_to_ingredient(index, inci_name:, cas_number:, concentration:, poisonous:, multiple_shades: nil, **extra_columns)
      raise IngredientContainsExtraColumnsError.new index if extra_columns.present? # rubocop:disable Style/RaiseArgs

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

    def range_row_to_ingredient(index, inci_name:, cas_number:, minimum_concentration:, maximum_concentration:, exact_concentration:, poisonous:, **extra_columns)
      raise IngredientContainsExtraColumnsError.new index if extra_columns.present? # rubocop:disable Style/RaiseArgs

      Ingredient.new(
        component:, inci_name:, cas_number:, poisonous: cast_boolean(poisonous),
        minimum_concentration:, maximum_concentration:, exact_concentration:
      )
    end

    def csv_header
      return [] if @csv_data.nil?

      @csv_data[0]
    end

    def ingredients_from_csv
      return [] if @csv_data.nil?

      @csv_data[1..]
    end

    def csv_header_template
      if component.range?
        headers = ["Ingredient name", "Minimum % w/w", "Maximum % w/w", "Exact % w/w", "CAS number", "Does NPIS need to know about it?"]
      else
        headers = ["Ingredient name", "% w/w", "CAS number", "Does NPIS need to know about it?"]
        headers << "Is it used for different shades?" if multiple_shades?
      end

      headers.join(",")
    end

    def replace_error_messages(messages)
      return if messages.blank?

      messages = messages.dup
      messages[:poisonous] = ["The selected file must provide `true` or `false` values to the NPIS column"] if messages[:poisonous].present?
      messages[:used_for_multiple_shades] = ["The selected file must provide `true` or `false` values to the multi-shade column"] if messages[:used_for_multiple_shades].present?

      messages
    end

    def cast_boolean(entry)
      { "TRUE" => true,
        "FALSE" => false,
        "true" => true,
        "false" => false }[entry]
    end
  end
end
