class Incident < ApplicationRecord
  belongs_to :investigation
  # This allows us to mark errors against individual date components, without storing them in the db
  attr_reader :day, :month, :year
end
