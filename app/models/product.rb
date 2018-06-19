class Product < ApplicationRecord
  default_scope { order(created_at: :desc) }
  has_many :investigations, dependent: :destroy
end
