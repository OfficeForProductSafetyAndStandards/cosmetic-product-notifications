class Product < ApplicationRecord
  default_scope { order(created_at: :desc) }
  has_many :investigation_products, dependent: :destroy
  has_many :investigations, through: :investigation_products
  has_many :images, dependent: :destroy, inverse_of: :product

  accepts_nested_attributes_for :images, reject_if: :all_blank, allow_destroy: true
end
