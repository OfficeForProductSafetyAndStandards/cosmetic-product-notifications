module SubmitRolesConcern
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
    !msa_user? # Could hardcode "true" but leave it as original for User for clarity
  end

  def can_view_nanomaterial_notification_files?
    true
  end

  def can_view_nanomaterial_review_period_end_date?
    true
  end
end
