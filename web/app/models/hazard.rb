class Hazard < ApplicationRecord
  belongs_to :investigation
  has_one_attached :risk_assessment
  attribute :set_risk_level
  enum risk_level: %i[none low medium serious severe], _suffix: true
end
