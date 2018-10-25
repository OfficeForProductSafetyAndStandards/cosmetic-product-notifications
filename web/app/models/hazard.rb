class Hazard < ApplicationRecord
  has_one :invesigation
  enum risk_level: %i[none low medium serious severe], _suffix: true
end
