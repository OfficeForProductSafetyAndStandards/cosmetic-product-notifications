class Hazard < ApplicationRecord
  belongs_to :investigation
  has_one_attached :risk_assessment
  enum risk_level: %i[none low medium serious severe], _suffix: true

  attribute :set_risk_level
end
