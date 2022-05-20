class ExactFormula < ApplicationRecord
  belongs_to :component

  validates_with CasNumberValidator

  before_save :normalise_cas_number

  def display_name
    "#{inci_name}: #{quantity}"
  end

private

  def normalise_cas_number
    cas_number&.delete!("-")
  end
end
