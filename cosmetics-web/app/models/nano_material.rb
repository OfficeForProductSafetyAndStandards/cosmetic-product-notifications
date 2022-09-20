class NanoMaterial < ApplicationRecord
  belongs_to :notification, optional: false

  has_many :component_nano_materials, dependent: :destroy
  has_many :components, through: :component_nano_materials
  has_many :nano_elements, -> { order(id: :asc) }, dependent: :destroy, inverse_of: :nano_material
  accepts_nested_attributes_for :nano_elements

  delegate :component_name, to: :component

  def nano_elements_required?
    nano_elements.any?(&:required?)
  end

  def name
    nano_elements.first.inci_name
  end
end
