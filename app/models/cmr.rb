class Cmr < ApplicationRecord
  CLONABLE_ATTRIBUTES = %i[
    name
    cas_number
    ec_number
  ].freeze

  include Clonable

  belongs_to :component

  validates :name, presence: true
  validate :cas_number_or_ec_number
  validates_with CasNumberValidator
  validates_with EcNumberValidator

  def display_name
    [name, cas_number, ec_number].reject(&:blank?).join(", ")
  end

private

  def cas_number_or_ec_number
    return if cas_number.present? || ec_number.present?

    errors.add(:base, "Provide CAS number or EC number")
    errors.add(:cas_number, :neither, message: "Enter the CAS number")
    errors.add(:ec_number, :neither, message: "Enter the EC number")
  end
end
