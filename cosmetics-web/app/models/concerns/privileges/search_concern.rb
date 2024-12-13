module Privileges
  module SearchConcern
    include AbstractConcern

    ### Roles and User Type Checks ###
    def poison_centre_user?
      has_role?(:poison_centre)
    end

    def opss_general_user?
      has_role?(:opss_general)
    end

    def opss_enforcement_user?
      has_role?(:opss_enforcement)
    end

    def opss_imt_user?
      has_role?(:opss_imt)
    end

    def opss_science_user?
      has_role?(:opss_science)
    end

    def trading_standards_user?
      has_role?(:trading_standards)
    end

    def opss_user?
      opss_general_user? || opss_enforcement_user? || opss_imt_user? || opss_science_user?
    end

    ### Privilege Checks ###
    def can_view_product_ingredients?
      poison_centre_user? || opss_enforcement_user? || opss_imt_user? || opss_science_user?
    end

    def can_view_ph?
      opss_enforcement_user? || opss_imt_user? || opss_science_user? || trading_standards_user?
    end

    def can_search_for_ingredients?
      !opss_general_user?
    end

    def can_view_nanomaterial_notification_files?
      opss_science_user?
    end

    def can_view_nanomaterial_review_period_end_date?
      opss_user? || trading_standards_user?
    end

    def can_view_notification_history?
      trading_standards_user? || opss_enforcement_user? || opss_imt_user?
    end

    ### Ingredient Viewing Permissions ###
    def can_view_product_ingredients_with_percentages?
      poison_centre_user? || opss_enforcement_user? || opss_imt_user?
    end

    def can_view_product_ingredients_without_percentages?
      trading_standards_user? || opss_science_user?
    end
  end
end
