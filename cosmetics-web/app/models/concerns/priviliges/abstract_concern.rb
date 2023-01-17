# Main module for defining user priviliges
#
# All of the priviliges definition should go here for the clarity and then should be reimplemented
# with concrete code in Submit or Search Concerns.
module Priviliges
  module AbstractConcern
    def can_view_product_ingredients?
      raise ArgumentError, "Implement role in each user type roles concern"
    end

    def can_view_nanomaterial_notification_files?
      raise ArgumentError, "Implement role in each user type roles concern"
    end

    def can_view_nanomaterial_review_period_end_date?
      raise ArgumentError, "Implement role in each user type roles concern"
    end
  end
end
