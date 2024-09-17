module Types
  class CustomDateTimeType < GraphQL::Schema::Scalar
    description "A custom date-time scalar that formats date-time as 'YYYY-MM-DDTHH:MM:SSZ' (ISO 8601)"

    # Coerce input coming from the GraphQL client
    def self.coerce_input(input_value, _context)
      begin
        # Parsing the input using Time.zone to maintain timezone awareness
        Time.zone.parse(input_value)
      rescue ArgumentError, TypeError
        raise GraphQL::CoercionError, "#{input_value.inspect} is not a valid DateTime"
      end
    end

    # Coerce the result that will be sent to the GraphQL client
    def self.coerce_result(ruby_value, _context)
      return nil if ruby_value.nil?

      # Return the output in ISO 8601 format with UTC timezone
      ruby_value.utc.iso8601
    end
  end
end
