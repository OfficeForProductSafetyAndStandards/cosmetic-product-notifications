class RangeFormula < ApplicationRecord
  belongs_to :component

  validates_with CasNumberValidator

  before_save :normalise_cas_number

private

  def normalise_cas_number
    self.cas_number = cas_number.presence&.delete("-")
  end
end
