class InvestigationProduct < ApplicationRecord
  belongs_to :investigation
  belongs_to :product
end
