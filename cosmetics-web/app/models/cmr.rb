class Cmr < ApplicationRecord
  belongs_to :component

  def display_name
    [name, display_cas_number, display_ec_number].reject(&:blank?).join(', ')
  end

  def display_cas_number
    cas_number.dup.insert(-2, "-").insert(-5, "-") if cas_number.present?
  end

  def display_ec_number
    ec_number.dup.insert(-2, "-").insert(-6, "-") if ec_number.present?
  end
end
