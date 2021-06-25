module ActiveModel
  module Types
    class GovUKDate < ActiveRecord::Type::Value
      def cast(value)
        DateParser.new(value).date
      end
    end
  end
end
