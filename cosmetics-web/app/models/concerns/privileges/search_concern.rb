module Privileges
  module SearchConcern
    include AbstractConcern

    def can_view_product_ingredients?
      !msa_user?
    end

    def can_view_ingredients_list?
      poison_centre_user?
    end

    def can_view_nanomaterial_notification_files?
      opss_science_user?
    end

    def can_view_nanomaterial_review_period_end_date?
      msa_user? || opss_science_user?
    end

    def poison_centre_user?
      poison_centre?
    end

    def msa_user?
      msa?
    end

    def opss_science_user?
      opss_science?
    end
  end
end
