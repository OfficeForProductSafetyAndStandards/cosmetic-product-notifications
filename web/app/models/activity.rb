class Activity < ApplicationRecord
  actable
  belongs_to :investigation

  has_one :source, as: :sourceable, dependent: :destroy
  accepts_nested_attributes_for :source

  validates :description, presence: true

  has_paper_trail
end
