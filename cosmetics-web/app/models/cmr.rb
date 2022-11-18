class Cmr < ApplicationRecord
  CLONABLE_ATTRIBUTES = %i[
    name
    cas_number
    ec_number
  ].freeze

  include Clonable

  belongs_to :component

  validates :name, presence: true
  validates :ec_number, format: { with: /\A(\d{3})-?(\d{3})-?(\d)\z/ }, allow_blank: true
  validate :ec_number_length
  validates_with CasNumberValidator

  before_save :remove_hyphens

  def display_name
    [name, display_cas_number, display_ec_number].reject(&:blank?).join(", ")
  end

  def display_cas_number
    cas_number.dup.insert(-2, "-").insert(-5, "-") if cas_number.present?
  end

  def display_ec_number
    ec_number.dup.insert(-2, "-").insert(-6, "-") if ec_number.present?
  end

private

  def remove_hyphens
    cas_number&.delete!("-")
    ec_number&.delete!("-")
  end

  def ec_number_length
    unless ec_number.blank? || ec_number.delete("^0-9").length == 7
      errors.add(:ec_number, "EC number must contain 7 digits")
    end
  end
end
