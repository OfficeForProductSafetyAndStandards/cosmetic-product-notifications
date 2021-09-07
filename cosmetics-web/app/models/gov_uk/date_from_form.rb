module GovUK
  class DateFromForm

    IncompleteDate = Struct.new(:year, :month, :day) do
      attr_reader :error_fields

      def initialize(*)
        @error_fields = {}
        super
      end

      def blank?
        year.blank? && month.blank? && day.blank?
      end

      def first_error_field
        error_fields.keys.first || :day
      end

      def error_on(part)
        @error_fields[part] = true
      end
    end

    class ValidatableDate < Date
      def first_error_field
        :day
      end
    end

    def initialize(value)
      @date = value
    end

    def prepare_date
      return nil if @date.nil?

      @date = date_from_string(@date) if @date.is_a?(String)

      return @date if @date.is_a?(Date) || @date.is_a?(Time)
      return struct_from_hash if date_values.all?(&:blank?)
      return struct_from_hash if date_values.any?(&:blank?)
      return struct_from_hash if date_values[1].negative? || date_values[2].negative?

      begin
        ValidatableDate.new(*date_values)
      rescue ArgumentError, RangeError
        struct_from_hash
      end
    end
    private

    def struct_from_hash
      IncompleteDate.new(@date[:year], @date[:month], @date[:day])
    end

    def date_from_string(date_as_string)
      Date.parse(date_as_string) rescue Date::Error # rubocop:disable Style/RescueModifier
    end

    def date_values
      @date_values ||= begin
                        @date.symbolize_keys! if @date.respond_to?(:symbolize_keys!)
                        @date.values_at(:year, :month, :day).map do |date_part|
                          date_part.is_a?(Integer) ? date_part : Integer(date_part.delete_prefix("0"))
                        rescue StandardError
                          nil
                        end
                      end
    end
  end
end
