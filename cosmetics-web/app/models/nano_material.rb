class NanoMaterial < ApplicationRecord
  belongs_to :notification, optional: true

  has_many :component_nano_materials, dependent: :destroy
  has_many :components, through: :component_nano_materials
  has_many :nano_elements, -> { order(id: :asc) }, dependent: :destroy, inverse_of: :nano_material
  accepts_nested_attributes_for :nano_elements

  validates :exposure_condition, presence: {
    on: :add_exposure_condition,
    message: lambda do |object, _|
      I18n.t(:missing, scope: %i[activerecord errors models nano_material attributes exposure_condition], component_name: object.component_name)
    end,
  }
  validates :exposure_routes, presence: true, on: :add_exposure_routes

  enum exposure_condition: {
    rinse_off: "rinse_off",
    leave_on: "leave_on",
  }

  delegate :component_name, to: :component

  def nano_elements_required?
    nano_elements.any?(&:required?)
  end

  def self.exposure_routes_options
    %i[dermal oral inhalation].freeze
  end

  def name
    nano_elements.first.inci_name
  end
end
