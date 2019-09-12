class Component < ApplicationRecord
  include AASM
  include NotificationProperties
  include NotificationPropertiesHelper
  include FileUploadConcern
  set_attachment_name :formulation_file
  set_allowed_types %w[application/pdf application/rtf text/plain].freeze
  set_max_file_size 30.megabytes

  belongs_to :notification

  has_many :exact_formulas, dependent: :destroy
  has_many :range_formulas, dependent: :destroy
  has_many :trigger_questions, dependent: :destroy
  has_many :cmrs, -> { order(id: :asc) }, dependent: :destroy, inverse_of: :component
  has_one :nano_material, dependent: :destroy
  has_one_attached :formulation_file

  accepts_nested_attributes_for :cmrs, reject_if: proc { |attributes| %i[name ec_number cas_number].all? { |key| attributes[key].blank? } }
  accepts_nested_attributes_for :nano_material

  validates :physical_form, presence: true, on: :add_physical_form
  validates :special_applicator, presence: true, on: :select_special_applicator_type
  validates :other_special_applicator, presence: true, on: :select_special_applicator_type, if: :other_special_applicator?
  validates :frame_formulation, presence: true, on: :select_frame_formulation
  validates :cmrs, presence: true, on: :add_cmrs
  validates :notification_type, presence: true, on: :select_formulation_type

  before_save :add_shades, if: :will_save_change_to_shades?
  before_save :remove_other_special_applicator, unless: :other_special_applicator?

  aasm whiny_transitions: false, column: :state do
    state :empty, initial: true
    state :component_complete, enter: :update_notification_state

    event :add_shades do
      transitions from: :empty, to: :component_complete
    end
  end

  def prune_blank_shades
    return if self[:shades].nil?

    self[:shades] = self[:shades].select(&:present?)
  end

  def sub_category
    Component.get_parent_category(sub_sub_category)
  end

  def root_category
    Component.get_parent_category(sub_category)
  end

  def belongs_to_category?(category)
    [root_category, sub_category, sub_sub_category&.to_sym].include?(category)
  end

  # This method is a temporary solution for elasticsearch indexing, until we implement filtering by categories
  def display_sub_category
    get_category_name(sub_category)
  end

  # This method is a temporary solution for elasticsearch indexing, until we implement filtering by categories
  def display_sub_sub_category
    get_category_name(sub_sub_category)
  end

  # This method is a temporary solution for elasticsearch indexing, until we implement filtering by categories
  def display_root_category
    get_category_name(root_category)
  end

  def nano_material_incomplete?
    nano_material&.nano_elements_incomplete?
  end

  def formulation_required?
    if range?
      !formulation_file.attached? && range_formulas&.empty?
    elsif exact?
      !formulation_file.attached? && exact_formulas&.empty?
    else
      false
    end
  end

  def self.get_parent_category(category)
    PARENT_OF_CATEGORY[category&.to_sym]
  end

  def self.get_parent_of_categories
    PARENT_OF_CATEGORY
  end

  def is_valid_multicomponent?
    name.present?
  end

private

  def update_notification_state
    notification&.set_single_or_multi_component!
  end

  def other_special_applicator?
    special_applicator == "other_special_applicator"
  end

  def remove_other_special_applicator
    self.other_special_applicator = nil
  end
end
