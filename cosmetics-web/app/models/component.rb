class Component < ApplicationRecord
  include AASM
  include NotificationProperties
  include NotificationPropertiesHelper
  include CategoryHelper
  include FileUploadConcern
  set_attachment_name :formulation_file
  set_allowed_types %w[application/pdf].freeze
  set_max_file_size 30.megabytes

  attr_writer :skip_name_uniqueness_on_import
  belongs_to :notification

  has_many :exact_formulas, dependent: :destroy
  has_many :range_formulas, dependent: :destroy
  has_many :trigger_questions, dependent: :destroy
  has_many :cmrs, -> { order(id: :asc) }, dependent: :destroy, inverse_of: :component
  has_one :nano_material, dependent: :destroy
  has_one_attached :formulation_file

  enum ph: {
    not_applicable: "not_applicable",
    lower_than_3: "lower_than_3",
    between_3_and_10: "between_3_and_10",
    above_10: "above_10",
    not_given: "not_given",
  }, _prefix: true

  accepts_nested_attributes_for :cmrs, reject_if: proc { |attributes| %i[name ec_number cas_number].all? { |key| attributes[key].blank? } }
  accepts_nested_attributes_for :nano_material

  scope :complete, -> { where(state: "component_complete") }

  validates :physical_form, presence: {
    on: :add_physical_form,
    message: lambda do |object, _|
               "Select the physical form of #{object.component_name}"
             end,
  }

  # Currently two components with no name are immediately created for
  # a notification when the user indicates that it is a kit/multi-component,
  # so the uniquness validation has to allow non-unique null values.
  validates :name, uniqueness: { scope: :notification_id, allow_nil: true, case_sensitive: false }, unless: -> { notification.via_zip_file? }

  validates :special_applicator, presence: true, on: :select_special_applicator_type

  validates :other_special_applicator, presence: true, on: :select_special_applicator_type, if: :other_special_applicator?

  validates :frame_formulation, presence: true, on: :select_frame_formulation
  validates :cmrs, presence: true, on: :add_cmrs
  validates :notification_type, presence: true, on: :select_formulation_type

  validates :ph, presence: { message: "Select the pH range of the product" }, on: :ph

  validates :maximum_ph, presence: { message: "Enter a maximum pH" }, if: -> { minimum_ph.present? }
  validates :minimum_ph, presence: { message: "Enter a minimum pH" }, if: -> { maximum_ph.present? }

  validates :maximum_ph, presence: { message: "Enter a maximum pH" }, on: :ph_range
  validates :minimum_ph, presence: { message: "Enter a minimum pH" }, on: :ph_range

  validate :maximum_ph_must_be_equal_or_above_minimum_ph, if: -> { maximum_ph.present? && minimum_ph.present? }

  validate :difference_between_maximum_and_minimum_ph, if: -> { maximum_ph.present? && minimum_ph.present? }

  validates :minimum_ph, numericality: { message: "Enter a value of 0 or higher for minimum pH", greater_than_or_equal_to: 0 }, if: -> { minimum_ph.present? }

  validates :minimum_ph, numericality: { message: "Enter a value of 14 or lower for minimum pH", less_than_or_equal_to: 14 }, if: -> { minimum_ph.present? }

  validates :maximum_ph, numericality: { message: "Enter a value of 0 or higher for maximum pH", greater_than_or_equal_to: 0 }, if: -> { maximum_ph.present? }

  validates :maximum_ph, numericality: { message: "Enter a value of 14 or lower for maximum pH", less_than_or_equal_to: 14 }, if: -> { maximum_ph.present? }

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

  def nano_material_required?
    nano_material && nano_material.nano_elements_required?
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

  def maximum_ph=(value)
    super(reject_non_decimal_strings(value))
  end

  def minimum_ph=(value)
    super(reject_non_decimal_strings(value))
  end

  def ph=(value)
    super(value)

    # Remove min and max pH if no longer required
    if ph_range_not_required?
      self.minimum_ph = nil
      self.maximum_ph = nil
    end
  end

  def ph_range_not_required?
    ph_between_3_and_10? || ph_not_applicable?
  end

  def component_name
    notification.is_multicomponent? ? name : "product"
  end

  def poisonous_ingredients_answer
    return if contains_poisonous_ingredients.nil?

    contains_poisonous_ingredients? ? "Yes" : "No"
  end

private

  # This takes any value and returns nil if the value
  # is a string but isn't a format which represents an
  # integer (10) or decimal (1.3). Otherwise, returns the value.
  #
  # This allows `.to_f` to be called on the result, without the
  # unexpected behaviour of strings such as `"N/A"` being converted
  # to 0.0
  def reject_non_decimal_strings(value)
    decimal_regex = /\A\s*\d+(?:\.\d+)?\s*\z/

    if value.is_a?(String) && value !~ decimal_regex
      nil
    else
      value
    end
  end

  def update_notification_state
    notification&.set_single_or_multi_component!
  end

  def other_special_applicator?
    special_applicator == "other_special_applicator"
  end

  def remove_other_special_applicator
    self.other_special_applicator = nil
  end

  def maximum_ph_must_be_equal_or_above_minimum_ph
    if maximum_ph < minimum_ph
      errors.add(:maximum_ph, "The maximum pH must be the same or higher than the minimum pH")
    end
  end

  def difference_between_maximum_and_minimum_ph
    if (maximum_ph - minimum_ph).round(2) > 1.0
      errors.add(:maximum_ph, "The maximum pH cannot be more than 1 higher than the minimum pH")
    end
  end
end
