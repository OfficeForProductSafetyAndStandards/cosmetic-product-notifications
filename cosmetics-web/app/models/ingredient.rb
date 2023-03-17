class Ingredient < ApplicationRecord
  CLONABLE_ATTRIBUTES = %i[
    inci_name
    cas_number
    used_for_multiple_shades
    exact_concentration
    range_concentration
    poisonous
  ].freeze
  NAME_LENGTH_LIMIT = 100

  include CasNumberConcern
  include Clonable

  belongs_to :component

  enum(
    range_concentration: {
      less_than_01_percent: "less_than_01_percent",
      greater_than_01_less_than_1_percent: "greater_than_01_less_than_1_percent",
      greater_than_1_less_than_5_percent: "greater_than_1_less_than_5_percent",
      greater_than_5_less_than_10_percent: "greater_than_5_less_than_10_percent",
      greater_than_10_less_than_25_percent: "greater_than_10_less_than_25_percent",
      greater_than_25_less_than_50_percent: "greater_than_25_less_than_50_percent",
      greater_than_50_less_than_75_percent: "greater_than_50_less_than_75_percent",
      greater_than_75_less_than_100_percent: "greater_than_75_less_than_100_percent",
    },
    _prefix: :range_concentration,
  )

  scope :poisonous, -> { where(poisonous: true) }
  scope :non_poisonous, -> { where(poisonous: false) }
  scope :range, -> { where.not(range_concentration: nil) }
  scope :exact, -> { where.not(exact_concentration: nil) }
  scope :unique_names, -> { unscoped.select(:inci_name).distinct }
  scope :by_name_asc, -> { order(inci_name: :asc) }
  scope :by_name_desc, -> { order(inci_name: :desc) }
  scope :unique_names_by_created_last, lambda {
    unscoped.select("ingredients.*")
            .joins("LEFT JOIN ingredients f2 on ingredients.inci_name = f2.inci_name AND ingredients.created_at > f2.created_at")
            .where("f2.id IS NULL")
            .order("ingredients.created_at DESC")
  }

  default_scope { order(created_at: :asc) }

  validates :inci_name, presence: true, ingredient_name_format: { message: :invalid }
  validates :inci_name, uniqueness: { scope: :component_id }, if: :validate_inci_name_uniqueness?
  validates :inci_name, length: { maximum: NAME_LENGTH_LIMIT }, on: :create

  validates :used_for_multiple_shades, inclusion: { in: [true, false] }, if: -> { used_for_multiple_shades_required? }

  # Exact and range concentration invalidate each other.
  validates :range_concentration, absence: true, if: -> { exact_concentration.present? }
  validates :exact_concentration, absence: true, if: -> { range_concentration.present? }

  validates :exact_concentration,
            presence: true,
            numericality: { allow_blank: true, greater_than: 0, less_than_or_equal_to: 100 },
            if: -> { range_concentration.blank? }

  validates :range_concentration, presence: true, if: -> { exact_concentration.blank? }
  validates :poisonous, inclusion: { in: [true, false] }, if: -> { exact_concentration.present? }

  validate :poisonous_on_exact_concentration
  validate :non_poisonous_exact_component_type
  validate :range_component_type

  def used_for_multiple_shades?
    used_for_multiple_shades == true
  end

private

  def validate_inci_name_uniqueness?
    return false if inci_name.blank? || !inci_name_changed?

    notification = component&.notification
    notification && !notification&.via_zip_file? && !notification&.deleted?
  end

  def poisonous_on_exact_concentration
    if poisonous? && exact_concentration.blank? && range_concentration.present?
      errors.add(:poisonous, :with_range_concentration)
    end
  end

  def range_component_type
    if range_concentration.present? && component && component.notification_type != "range"
      errors.add(:range_concentration, :non_range_component)
    end
  end

  def non_poisonous_exact_component_type
    if !poisonous &&
        exact_concentration.present? &&
        range_concentration.blank? &&
        component &&
        component.notification_type != "exact"
      errors.add(:exact_concentration, :non_poisonous_wrong_component_type)
    end
  end

  # TODO: Fix form so poisonous range ingredients require used_for_multiple_shades field too.
  def used_for_multiple_shades_required?
    exact_concentration.present? && component && component.multi_shade? && !component.range?
  end
end
