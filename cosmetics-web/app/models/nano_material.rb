class NanoMaterial < ApplicationRecord
  belongs_to :component

  has_many :nano_elements, -> { order(id: :asc) }, dependent: :destroy, inverse_of: :nano_material
  accepts_nested_attributes_for :nano_elements

  validates :exposure_condition, presence: true, on: :add_exposure_condition
  validates :exposure_routes, presence: true, on: :add_exposure_routes

  enum exposure_condition: {
    rinse_off: "rinse_off",
    leave_on: "leave_on"
  }

  def nano_elements_incomplete?
    nano_elements.any?(&:incomplete?)
  end

  def self.exposure_routes_options
    %i(dermal oral inhalation).freeze
  end
end
