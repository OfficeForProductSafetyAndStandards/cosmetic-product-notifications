class InvestigationProduct < ApplicationRecord
  belongs_to :investigation
  belongs_to :product

  default_scope { order(created_at: :asc) }
end
