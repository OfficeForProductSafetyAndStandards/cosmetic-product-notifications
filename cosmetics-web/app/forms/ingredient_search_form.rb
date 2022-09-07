class IngredientSearchForm < Form
  attribute :q
  attribute :exact_or_any_match, default: OpenSearchQuery::Ingredient::ANY_MATCH
  attribute :date_from, :govuk_date
  attribute :date_to, :govuk_date
  attribute :sort_by, default: OpenSearchQuery::Ingredient::SORT_BY_NONE

  validates :date_from,
            presence: true,
            real_date: true,
            complete_date: true,
            not_in_future: true,
            if: :date_range_selected?

  validates :date_to,
            presence: true,
            real_date: true,
            complete_date: true,
            if: :date_range_selected?

  validate :date_from_lower_than_date_to

  def filters_present?
    false
  end

  def date_from_for_search
    return unless valid?

    return date_from if date_range_selected?
  end

  def date_to_for_search
    return unless valid?

    return date_to if date_range_selected?
  end

  def date_from_lower_than_date_to
    if date_range_selected? && date_from.is_a?(Date) && date_to.is_a?(Date) && (date_from > date_to)
      errors.add(:date_to, :date_from_is_later_than_date_to)
    end
  end

  def date_range_selected?
    date_from.present? || date_to.present?
  end
end
