class Investigation < ApplicationRecord
  default_scope { order(created_at: :desc) }
  belongs_to :product
end
