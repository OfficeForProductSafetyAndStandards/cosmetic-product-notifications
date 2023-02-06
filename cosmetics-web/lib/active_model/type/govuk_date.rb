module ActiveModel
  module Types
    class GovUkDate < ActiveRecord::Type::Value
      def cast(value)
        GovUk::DateFromForm.new(value).prepare_date
      end
    end
  end
end
