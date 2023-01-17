# frozen_string_literal: true

require "active_support/core_ext/object/try"

# Copied from
# activemodel/lib/active_model/type/float.rb
#
# Just want to prevent casting of "20-20" to 20.0
# Only change to original Float type is one line in cast_value line - see git history for details
module ActiveModel
  module Type
    class StrictFloat < Value # :nodoc:
      include Helpers::Numeric

      def type
        :strict_float
      end

      def type_cast_for_schema(value)
        return "::Float::NAN" if value.try(:nan?)

        case value
        when ::Float::INFINITY then "::Float::INFINITY"
        when -::Float::INFINITY then "-::Float::INFINITY"
        else super
        end
      end

    private

      def cast_value(value)
        case value
        when ::Float then value
        when "Infinity" then ::Float::INFINITY
        when "-Infinity" then -::Float::INFINITY
        when "NaN" then ::Float::NAN
        else
          begin
            Float(value)
          rescue ArgumentError
            nil
          end
        end
      end
    end
  end
end
