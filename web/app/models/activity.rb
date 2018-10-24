class Activity < ApplicationRecord
  belongs_to :investigation

  has_one :source, as: :sourceable, dependent: :destroy
  belongs_to :business, optional: true
  belongs_to :product, optional: true

end
