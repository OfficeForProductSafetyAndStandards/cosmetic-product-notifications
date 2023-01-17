module ActiveModel
  module Type
    class GovUKDate < Value
      def cast(value)
        GovUK::DateFromForm.new(value).prepare_date
      end
    end
  end
end
