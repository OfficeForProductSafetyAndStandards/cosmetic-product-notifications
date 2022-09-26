class NotificationSearchForm < Form
  extend CategoryHelper

  FILTER_BY_DATE_EXACT = "by_date_exact".freeze
  FILTER_BY_DATE_RANGE = "by_date_range".freeze

  CATEGORIES = get_main_categories.map { |c| get_category_name(c) }
  SORT_WITH_QUERY_OPTIONS = {
    "Relevance" => OpensearchQuery::SCORE_SORTING,
    "Newest" => OpensearchQuery::DATE_DESCENDING_SORTING,
    "Oldest" => OpensearchQuery::DATE_ASCENDING_SORTING,
  }.freeze

  SORT_WITHOUT_QUERY_OPTIONS = {
    "Newest" => OpensearchQuery::DATE_DESCENDING_SORTING,
    "Oldest" => OpensearchQuery::DATE_ASCENDING_SORTING,
  }.freeze

  attribute :q
  attribute :category

  attribute :date_filter

  attribute :date_from, :govuk_date
  attribute :date_to, :govuk_date
  attribute :date_exact, :govuk_date

  attribute :sort_by

  attribute :search_fields, default: OpensearchQuery::SEARCH_ALL_FIELDS

  attribute :match_similar

  validates :date_exact,
            presence: true,
            real_date: true,
            complete_date: true,
            not_in_future: true,
            if: :date_exact_selected?

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

  validate :date_from_lower_then_date_to

  def sorting_options
    q.present? ? SORT_WITH_QUERY_OPTIONS : SORT_WITHOUT_QUERY_OPTIONS
  end

  def date_from_for_search
    return unless valid?

    return date_exact if date_exact_selected?
    return date_from if date_range_selected?
  end

  def date_to_for_search
    return unless valid?

    return date_exact if date_exact_selected?
    return date_to if date_range_selected?
  end

  def date_exact_selected?
    date_filter == FILTER_BY_DATE_EXACT
  end

  def date_range_selected?
    date_filter == FILTER_BY_DATE_RANGE
  end

  def date_from_lower_then_date_to
    if date_range_selected? && date_from.is_a?(Date) && date_to.is_a?(Date) && (date_from > date_to)
      errors.add(:date_to, :date_from_is_later_than_date_to)
    end
  end
end
