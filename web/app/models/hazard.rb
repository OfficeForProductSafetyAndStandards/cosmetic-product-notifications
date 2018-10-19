class Hazard < ApplicationRecord
  enum risk_level: %i[unable_to_set low medium serious severe], _suffix: true
end
