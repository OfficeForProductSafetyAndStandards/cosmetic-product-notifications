module Priviliges
  module SubmitConcern
    include AbstractConcern

    def poison_centre_user?
      false
    end

    def msa_user?
      false
    end

    def opss_science_user?
      false
    end

    def can_view_product_ingredients?
      true
    end

    def can_view_nanomaterial_notification_files?
      true
    end

    def can_view_nanomaterial_review_period_end_date?
      true
    end
  end
end
