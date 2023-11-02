class Ingredient < ApplicationRecord
  CLONABLE_ATTRIBUTES = %i[
    inci_name
    cas_number
    used_for_multiple_shades
    exact_concentration
    maximum_concentration
    minimum_concentration
    range_concentration
    poisonous
  ].freeze
  NAME_LENGTH_LIMIT = 100

  include Clonable

  belongs_to :component

  scope :poisonous, -> { where(poisonous: true) }
  scope :non_poisonous, -> { where(poisonous: false) }
  scope :range, -> { where(exact_concentration: nil) }
  scope :exact, -> { where.not(exact_concentration: nil) }
  scope :unique_names, -> { unscoped.select(:inci_name).distinct }

  scope :default_order, -> { order(id: :asc) }
  scope :by_concentration_desc, -> { order(exact_concentration: :desc, maximum_concentration: :desc, minimum_concentration: :desc) }

  validates :inci_name, presence: true, ingredient_name_format: { message: :invalid }
  validates :inci_name, uniqueness: { scope: :component_id }, if: :validate_inci_name_uniqueness?
  validates :inci_name, length: { maximum: NAME_LENGTH_LIMIT }, on: %i[create bulk_upload]

  validates :poisonous, inclusion: { in: [true, false] }, if: -> { range? || exact_concentration.present? }

  validates :exact_concentration,
            presence: true,
            numericality: { allow_blank: true, greater_than: 0, less_than_or_equal_to: 100 },
            if: lambda {
                  (exact? && !multi_shade?) ||
                    (exact? && multi_shade? && used_for_multiple_shades == false) ||
                    (range? && poisonous == true)
                }

  validates :maximum_exact_concentration,
            presence: true,
            numericality: { allow_blank: true, greater_than: 0, less_than_or_equal_to: 100 },
            if: -> { exact? && multi_shade? && used_for_multiple_shades == true }

  validates :minimum_concentration,
            presence: true,
            numericality: { allow_blank: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
            if: -> { range? && poisonous == false }

  validates :maximum_concentration,
            presence: true,
            numericality: { allow_blank: true, greater_than: 0, less_than_or_equal_to: 100 },
            if: -> { range? && poisonous == false }

  validates :exact_concentration,
            absence: true,
            if: -> { range? && poisonous == false },
            on: :bulk_upload

  validates :minimum_concentration, :maximum_concentration,
            absence: true,
            if: -> { range? && poisonous == true },
            on: :bulk_upload

  validate :maximum_minimum_concentration_range, if: -> { range? && poisonous == false }

  validates :used_for_multiple_shades, inclusion: { in: [true, false] }, if: -> { exact? && multi_shade? }

  validates_with CasNumberValidator

  delegate :range?, to: :component
  delegate :multi_shade?, to: :component

  before_save :reset_concentration_fields

  def exact?
    !range?
  end

  def maximum_exact_concentration
    exact_concentration if used_for_multiple_shades?
  end

  def maximum_exact_concentration=(val)
    self.exact_concentration = val if used_for_multiple_shades?
  end

private

  def reset_concentration_fields
    if range?
      if poisonous
        self.minimum_concentration = nil
        self.maximum_concentration = nil
      else
        self.exact_concentration = nil
      end
    end
  end

  def validate_inci_name_uniqueness?
    return false if inci_name.blank? || !inci_name_changed?

    notification = component&.notification
    notification && !notification&.via_zip_file? && !notification&.deleted?
  end

  def maximum_minimum_concentration_range
    return unless maximum_concentration && minimum_concentration

    unless maximum_concentration >= minimum_concentration
      errors.add(:maximum_concentration,
                 message: "Maximum concentration must be greater than the minimum concentration")
    end
  end
end
