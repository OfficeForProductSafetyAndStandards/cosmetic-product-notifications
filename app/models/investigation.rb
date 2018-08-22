class Investigation < ApplicationRecord
  validates :title, presence: true
  default_scope { order(updated_at: :desc) }

  has_many :investigation_products, dependent: :destroy
  has_many :products, through: :investigation_products

  has_many :investigation_businesses, dependent: :destroy
  has_many :businesses, through: :investigation_businesses

  has_many :activities, dependent: :destroy
  belongs_to :assignee, class_name: "User", optional: true
  has_one_attached :image
  has_one :source, as: :sourceable, dependent: :destroy

  accepts_nested_attributes_for :products
  accepts_nested_attributes_for :businesses
  accepts_nested_attributes_for :source
  accepts_nested_attributes_for :investigation_products, allow_destroy: true
  accepts_nested_attributes_for :investigation_businesses, allow_destroy: true

  has_paper_trail

  enum risk_level: [
    :low,
    :medium,
    :serious,
    :severe
  ], _suffix: true

  enum sensitivity: [
    :low,
    :medium,
    :high
  ], _suffix: true
end
