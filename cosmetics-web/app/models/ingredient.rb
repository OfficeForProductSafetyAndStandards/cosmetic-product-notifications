class Ingredient < ApplicationRecord
  include CasNumberConcern

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

  validates :inci_name, presence: true
  validate :unique_inci_name, if: :inci_name_changed?

  # Exact and range concentration invalidate each other.
  validates :range_concentration, absence: true, if: -> { exact_concentration.present? }
  validates :exact_concentration, absence: true, if: -> { range_concentration.present? }

  validates :exact_concentration,
            presence: true,
            numericality: { allow_blank: true, greater_than: 0, less_than_or_equal_to: 100 },
            if: -> { range_concentration.blank? }

  validates :range_concentration, presence: true, if: -> { exact_concentration.blank? }

  validate :poisonous_on_exact_concentration, unless: :exact_concentration?
  validate :non_poisonous_exact_component_type, unless: :range_concentration?
  validate :range_component_type

private

  def unique_inci_name
    return if inci_name.blank? || component.blank?

    notification = component.notification
    return if notification&.via_zip_file? || notification&.deleted?
    return if inci_name_was&.casecmp(inci_name)&.zero? # Do not validate uniqueness if name is unchanged.

    if self.class.where(component_id: component).where("LOWER(inci_name) = ?", inci_name.downcase).any?
      errors.add(:inci_name, :taken)
    end
  end

  def poisonous_on_exact_concentration
    if poisonous? && range_concentration.present?
      errors.add(:poisonous, :with_range_concentration)
    end
  end

  def range_component_type
    if range_concentration.present? && component && component.notification_type != "range"
      errors.add(:range_concentration, :non_range_component)
    end
  end

  def non_poisonous_exact_component_type
    if exact_concentration.present? && !poisonous && component && component.notification_type != "exact"
      errors.add(:exact_concentration, :non_poisonous_wrong_component_type)
    end
  end
end
