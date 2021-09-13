module ActiveModel
  module Types
    class GovUKDate < ActiveRecord::Type::Value
      def cast(value)
        GovUK::DateFromForm.new(value).prepare_date
      end
    end
  end
end
