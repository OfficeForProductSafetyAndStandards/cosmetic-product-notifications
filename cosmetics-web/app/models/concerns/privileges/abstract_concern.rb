# Main module for defining user priviliges
#
# All of the priviliges definition should go here for the clarity and then should be reimplemented
# with concrete code in Submit or Search Concerns.
#
# It can be noticed that some of the priviliges are applicable only to one domain, and the design
# forces them to be common for both domains. When its true, it simplifies code a lot and until
# it will become cumbersome to maintain it is recommend to keep it simple.
# Please note that priviles and roles are mixed here, but again - its for sake of simplicity.
module Privileges
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

    def poison_centre_user?
      false
    end

    def msa_user?
      false
    end

    def opss_science_user?
      false
    end
  end
end
