class Activity < ApplicationRecord
  belongs_to :investigation

  has_one :source, as: :sourceable, dependent: :destroy

  has_paper_trail
end
