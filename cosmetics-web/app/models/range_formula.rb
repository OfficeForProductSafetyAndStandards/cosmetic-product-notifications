class RangeFormula < ApplicationRecord
  include CasNumberConcern

  belongs_to :component
end
