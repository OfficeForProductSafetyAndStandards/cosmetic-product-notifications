# Helper class which can parse a date from a hash of
# {day: "1", month: "2", year: "2020"}
#
# If the date is invalid, or any parts are missing, then
# the input date is returned as a struct
class DateParser
  def initialize(date)
    @date = date
  end

  def date
    return nil if @date.nil?

    @date = date_from_string(@date) if @date.is_a?(String)

    return @date            if @date.is_a?(Date) || @date.is_a?(Time)
    return nil              if date_values.all?(&:blank?)
    return struct_from_hash if date_values.any?(&:blank?)
    return struct_from_hash if date_values[1].negative? || date_values[2].negative?

    begin
      Date.new(*date_values)
    rescue ArgumentError, RangeError
      struct_from_hash
    end
  end

private

  def struct_from_hash
    OpenStruct.new(year: @date[:year], month: @date[:month], day: @date[:day])
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
