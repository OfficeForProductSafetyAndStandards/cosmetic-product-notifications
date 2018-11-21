class Incident < ApplicationRecord
  include DateConcern
  belongs_to :investigation
end
