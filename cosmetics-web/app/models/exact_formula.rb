class ExactFormula < ApplicationRecord
  belongs_to :component

  def to_s
    inci_name + ': ' + quantity.to_s
  end
end
