class NanoMaterial < ApplicationRecord
  belongs_to :component

  has_many :nano_elements, -> { order(id: :asc) }, dependent: :destroy, inverse_of: :nano_material
  accepts_nested_attributes_for :nano_elements

  validates :exposure_condition, presence: {
    on: :add_exposure_condition,
    message: ->(object,_) do
      I18n.t(:missing, scope: [:activerecord, :errors, :models, :nano_material, :attributes, :exposure_condition], component_name: object.component_name)
    end
  }
  validates :exposure_routes, presence: true, on: :add_exposure_routes

  enum exposure_condition: {
    rinse_off: "rinse_off",
    leave_on: "leave_on"
  }

  delegate :component_name, to: :component

  def nano_elements_incomplete?
    nano_elements.any?(&:incomplete?)
  end

  def self.exposure_routes_options
    %i(dermal oral inhalation).freeze
  end
end
