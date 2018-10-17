class Hazard < ApplicationRecord
    enum risk_level: %i[low medium serious severe], _suffix: true
end
