class Cmr < ApplicationRecord
  belongs_to :component

  def to_s
    [name, ec_number, cas_number].join(', ')
  end
end
