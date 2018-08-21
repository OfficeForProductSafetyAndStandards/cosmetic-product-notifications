class RapexImage < ApplicationRecord
  belongs_to :product

  has_paper_trail
end
