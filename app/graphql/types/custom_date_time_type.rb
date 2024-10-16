module Types
  class CustomDateTimeType < GraphQL::Schema::Scalar
    description "A custom date-time scalar that formats date-time as 'YYYY-MM-DDTHH:MM:SSZ' (ISO 8601)"

    def self.coerce_input(input_value, _context)
      Time.zone.parse(input_value)
    rescue ArgumentError, TypeError
      raise GraphQL::CoercionError, "#{input_value.inspect} is not a valid DateTime"
    end

    def self.coerce_result(ruby_value, _context)
      return nil if ruby_value.nil?

      ruby_value.utc.iso8601
    end
  end
end
