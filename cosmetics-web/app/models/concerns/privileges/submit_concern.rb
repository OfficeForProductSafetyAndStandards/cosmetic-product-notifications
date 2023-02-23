module Privileges
  module SubmitConcern
    include AbstractConcern

    def can_view_product_ingredients?
      true
    end

    def can_view_ingredients_list?
      true
    end

    def can_view_nanomaterial_notification_files?
      true
    end

    def can_view_nanomaterial_review_period_end_date?
      true
    end

    def can_view_responsible_person_address_history?
      true
    end
  end
end
