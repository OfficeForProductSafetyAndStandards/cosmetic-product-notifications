class RangeFormula < ApplicationRecord
  belongs_to :component

  def to_s
    inci_name + ': ' + range.to_s
  end
end
