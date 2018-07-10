class Investigation < ApplicationRecord
  default_scope { order(updated_at: :desc) }
  has_many :investigation_products, dependent: :destroy
  has_many :products, through: :investigation_products
  has_many :activities, dependent: :destroy
  belongs_to :assignee, class_name: "User", optional: true
  has_one_attached :image
  belongs_to :source

  accepts_nested_attributes_for :products
  accepts_nested_attributes_for :investigation_products, allow_destroy: true

  has_paper_trail
end
