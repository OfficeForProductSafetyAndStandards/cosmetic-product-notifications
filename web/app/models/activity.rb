class Activity < ApplicationRecord
  belongs_to :investigation

  has_one :source, as: :sourceable, dependent: :destroy
  accepts_nested_attributes_for :source

  has_paper_trail
end
