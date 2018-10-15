class Reporter < ApplicationRecord
  validates :reporter_type, presence: { message: "Please select reporter type" }
end
