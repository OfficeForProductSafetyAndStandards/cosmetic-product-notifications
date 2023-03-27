class IngredientSearchForm < Form
  SORT_WITH_QUERY_OPTIONS = {
    "Relevance" => OpenSearchQuery::Ingredient::SCORE_SORTING,
    "Newest" => OpenSearchQuery::Ingredient::DATE_DESCENDING_SORTING,
    "Oldest" => OpenSearchQuery::Ingredient::DATE_ASCENDING_SORTING,
  }.freeze

  SORT_WITHOUT_QUERY_OPTIONS = {
    "Newest" => OpenSearchQuery::Ingredient::DATE_DESCENDING_SORTING,
    "Oldest" => OpenSearchQuery::Ingredient::DATE_ASCENDING_SORTING,
  }.freeze

  FILTER_BY_DATE_RANGE = "by_date_range".freeze

  attribute :q
  attribute :exact_or_any_match, default: OpenSearchQuery::Ingredient::ANY_MATCH

  attribute :date_filter

  attribute :date_from, :govuk_date
  attribute :date_to, :govuk_date
  attribute :group_by, default: OpenSearchQuery::Ingredient::GROUP_BY_NONE

  attribute :sort_by, default: OpenSearchQuery::Ingredient::SCORE_SORTING

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
    date_filter == FILTER_BY_DATE_RANGE
  end

  def sorting_options
    q.present? ? SORT_WITH_QUERY_OPTIONS : SORT_WITHOUT_QUERY_OPTIONS
  end
end
