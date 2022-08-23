class ExactFormula < ApplicationRecord
  include CasNumberConcern

  belongs_to :component

  validates :inci_name, presence: true
  validates :quantity,
            presence: true,
            numericality: { allow_blank: true, greater_than: 0, less_than_or_equal_to: 100 }

  def display_name
    "#{inci_name}: #{quantity}"
  end
end
