class NanoMaterial < ApplicationRecord
  belongs_to :component

  has_many :nano_elements, -> { order(id: :asc) }, dependent: :destroy, inverse_of: :nano_material

  validates :exposure_condition, presence: true, on: :add_exposure_condition
  validates :exposure_routes, presence: true, on: :add_exposure_routes

  accepts_nested_attributes_for :nano_elements

  enum exposure_condition: {
    rinse_off: "rinse_off",
    leave_on: "leave_on"
  }

  has_many :nano_elements, dependent: :destroy
end
