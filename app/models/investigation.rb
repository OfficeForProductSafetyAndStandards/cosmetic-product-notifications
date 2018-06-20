class Investigation < ApplicationRecord
  default_scope { order(created_at: :desc) }
  has_and_belongs_to_many :products
end
