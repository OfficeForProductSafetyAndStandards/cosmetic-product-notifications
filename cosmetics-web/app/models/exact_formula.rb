class ExactFormula < ApplicationRecord
  belongs_to :component

  def display_name
    "#{inci_name}: #{quantity}"
  end
end
