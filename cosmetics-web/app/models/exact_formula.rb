class ExactFormula < ApplicationRecord
  belongs_to :component

  validates :inci_name, presence: true
  validates :quantity, presence: true
  validates_with CasNumberValidator

  before_save :normalise_cas_number

  def display_name
    "#{inci_name}: #{quantity}"
  end

private

  def normalise_cas_number
    self.cas_number = cas_number.presence&.delete("-")
  end
end
