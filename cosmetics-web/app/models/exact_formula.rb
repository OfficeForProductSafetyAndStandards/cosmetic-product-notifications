class ExactFormula < ApplicationRecord
  include CasNumberConcern

  belongs_to :component

  validates :inci_name, presence: true
  validates :quantity, presence: true

  def display_name
    "#{inci_name}: #{quantity}"
  end
end
