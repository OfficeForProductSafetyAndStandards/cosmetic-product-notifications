class Product < ApplicationRecord
  default_scope { order(created_at: :desc) }
  has_many :investigation_products, dependent: :destroy
  has_many :investigations, through: :investigation_products
end
