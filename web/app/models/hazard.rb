class Hazard < ApplicationRecord
  belongs_to :investigation
  enum risk_level: %i[none low medium serious severe], _suffix: true
end
