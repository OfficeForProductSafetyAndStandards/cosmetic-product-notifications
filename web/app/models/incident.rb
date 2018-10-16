class Incident < ApplicationRecord
  belongs_to :investigation
  # These allows us to keep the value of and mark errors against individual date components, without persisting them
  attr_accessor :day, :month, :year
end
