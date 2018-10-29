class Hazard < ApplicationRecord
  belongs_to :investigation
  has_many_attached :documents
  enum risk_level: %i[none low medium serious severe], _suffix: true
end
