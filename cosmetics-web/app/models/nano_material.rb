class NanoMaterial < ApplicationRecord
  belongs_to :component

  has_many :nano_elements, dependent: :destroy
end
