class Business < ApplicationRecord
  validates :company_name, presence: true
  default_scope { order(created_at: :desc) }
  has_one :source, as: :sourceable, dependent: :destroy

  accepts_nested_attributes_for :source

  has_paper_trail
end
