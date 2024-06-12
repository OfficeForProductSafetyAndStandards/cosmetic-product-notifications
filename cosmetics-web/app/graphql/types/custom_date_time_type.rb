module Types
  class CustomDateTimeType < GraphQL::Schema::Scalar
    description "A custom date-time scalar that formats date-time as 'YYYY-MM-DD HH:MM:SS'"

    def self.coerce_input(input_value, _context)
      Time.zone.parse(input_value)
    end

    def self.coerce_result(ruby_value, _context)
      ruby_value.strftime('%Y-%m-%d %H:%M:%S')
    end
  end
end