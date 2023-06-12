# Main module for defining user privileges.
#
# All of the privileges definitions should go here for clarity and then should be reimplemented
# with concrete code in Submit or Search Concerns.
#
# It can be noticed that some of the privileges are applicable only to one domain, and the design
# forces them to be common for both domains. When its true, it simplifies code a lot and until
# it will become cumbersome to maintain it is recommend to keep it simple.
# Please note that privileges and roles are mixed here, but again - its for sake of simplicity.
module Privileges
  module AbstractConcern
    def can_view_product_ingredients?
      raise ArgumentError, "Implement role in each user type roles concern"
    end

    def can_view_ingredients_list?
      raise ArgumentError, "Implement role in each user type roles concern"
    end

    def can_view_nanomaterial_notification_files?
      raise ArgumentError, "Implement role in each user type roles concern"
    end

    def can_view_nanomaterial_review_period_end_date?
      raise ArgumentError, "Implement role in each user type roles concern"
    end

    def can_view_responsible_person_address_history?
      raise ArgumentError, "Implement role in each user type roles concern"
    end

    def can_view_notification_history?
      raise ArgumentError, "Implement role in each user type roles concern"
    end

    def poison_centre_user?
      false
    end

    def opss_user?
      false
    end

    def opss_general_user?
      false
    end

    def opss_enforcement_user?
      false
    end

    def opss_science_user?
      false
    end

    def trading_standards_user?
      false
    end
  end
end
