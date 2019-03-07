class Component < ApplicationRecord
  include AASM
  include NotificationProperties
  include CpnpHelper

  belongs_to :notification

  has_many :exact_formulas, dependent: :destroy
  has_many :range_formulas, dependent: :destroy
  has_many :trigger_questions, dependent: :destroy
  has_many :cmrs, dependent: :destroy
  has_many :nano_materials, dependent: :destroy
  has_one_attached :formulation_file

  before_save :add_shades, if: :will_save_change_to_shades?

  validate :attached_file_is_correct_type?
  validate :attached_file_is_within_allowed_size?

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
    get_parent_category(sub_sub_category)
  end

  def root_category
    get_parent_category(sub_category)
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
  
  def formulation_required?
    if range?
      !formulation_file.attached? && range_formulas&.empty?
    elsif exact?
      !formulation_file.attached? && exact_formulas&.empty?
    else
      false
    end
  end

  ALLOWED_CONTENT_TYPES = %w[application/pdf application/rtf text/plain].freeze
  MAX_FILE_SIZE_BYTES = 30.megabytes

  def self.get_content_types
    ALLOWED_CONTENT_TYPES
  end

  def self.get_max_file_size
    MAX_FILE_SIZE_BYTES
  end

private

  def update_notification_state
    notification&.set_single_or_multi_component!
  end

  def get_parent_category(category)
    PARENT_OF_CATEGORY[category]
  end

  def attached_file_is_correct_type?
    unless formulation_file.attachment.nil? || Component.get_content_types.include?(formulation_file.blob.content_type)
      errors.add :formulation_file, "must be one of " + Component.get_content_types.join(", ")
    end
  end

  def attached_file_is_within_allowed_size?
    unless formulation_file.attachment.nil? || formulation_file.blob.byte_size <= Component.get_max_file_size
      errors.add :formulation_file, "must be smaller than #{Component.get_max_file_size / 1.megabyte}MB"
    end
  end
end
