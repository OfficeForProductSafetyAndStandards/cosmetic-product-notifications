class NotificationSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  extend CategoryHelper

  FILTER_BY_DATE_EXACT = 'by_date_exact'.freeze
  FILTER_BY_DATE_RANGE = 'by_date_range'.freeze

  CATEGORIES = get_main_categories.map { |c| get_category_name(c) }

  attribute :q
  attribute :category

  attribute :date_filter

  attribute :date_from, :govuk_date
  attribute :date_to, :govuk_date
  attribute :date_exact, :govuk_date
  # attribute :date_from_day
  # attribute :date_from_month
  # attribute :date_from_year

  # attribute :date_to_day
  # attribute :date_to_month
  # attribute :date_to_year

  # attribute :date_exact_day
  # attribute :date_exact_month
  # attribute :date_exact_year

  # validates :date_exact_year, presence: true, if: :validate_exact_date?
  # validates :date_exact_month, presence: true, if: :validate_exact_date?
  # validates :date_exact_day, presence: true, if: :validate_exact_date?

  # validate :date_exact_validation

  def from_date
    return if !valid?

    "2021-06-05"
  end

  def to_date
    return if !valid?

    "2021-06-08"
  end

  def [](field)
    public_send(field.to_sym)
  end

  def validate_exact_date?
    date_filter == FILTER_BY_DATE_EXACT
  end
end
