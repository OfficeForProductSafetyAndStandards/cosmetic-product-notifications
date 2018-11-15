class CorrectiveAction < ApplicationRecord
  belongs_to :investigation
  belongs_to :business
  belongs_to :product

end
