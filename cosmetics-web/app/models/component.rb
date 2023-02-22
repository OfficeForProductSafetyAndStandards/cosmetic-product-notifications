class Component < ApplicationRecord
  CLONABLE_ATTRIBUTES = %i[
    shades
    notification_type
    frame_formulation
    sub_sub_category
    name
    physical_form
    special_applicator
    other_special_applicator
    contains_poisonous_ingredients
    minimum_ph
    maximum_ph
    ph
    exposure_condition
    exposure_routes
    routing_questions_answers
    category
    unit
  ].freeze
  include AASM
  include NotificationProperties
  include NotificationPropertiesHelper
  include CategoryHelper
  include Clonable
  include FileUploadConcern
  include RoutingQuestionCacheConcern

  set_attachment_name :formulation_file
  set_allowed_types %w[application/pdf].freeze
  set_max_file_size 30.megabytes

  attr_writer :skip_name_uniqueness_on_import

  belongs_to :notification, touch: true

  has_many :ingredients, dependent: :destroy
  has_many :trigger_questions, dependent: :destroy
  has_many :cmrs, -> { order(id: :asc) }, dependent: :destroy, inverse_of: :component
  has_many :component_nano_materials
  has_many :nano_materials, through: :component_nano_materials
  has_one_attached :formulation_file

  delegate :responsible_person, to: :notification

  enum ph: {
    not_applicable: "not_applicable",
    lower_than_3: "lower_than_3",
    between_3_and_10: "between_3_and_10",
    above_10: "above_10",
    not_given: "not_given",
  }, _prefix: true

  accepts_nested_attributes_for :cmrs, reject_if: proc { |attributes| %i[name ec_number cas_number].all? { |key| attributes[key].blank? } }

  scope :complete, -> { where(state: "component_complete") }

  validates :physical_form, presence: {
    on: :add_physical_form,
    message: lambda do |object, _|
               "Select the physical form of #{object.component_name}"
             end,
  }

  # Currently two components with no name are immediately created for
  # a notification when the user indicates that it is a kit/multi-component,
  # so the uniqueness validation has to allow non-unique null values.
  validates :name, uniqueness: { scope: :notification_id, allow_nil: true, case_sensitive: false },
                   unless: -> { notification.via_zip_file? },
                   presence: { if: -> { notification.reload.components.where.not(id:).count.positive? }, on: :add_component_name }

  validates :special_applicator, presence: true, on: :select_special_applicator_type

  validates :other_special_applicator, presence: true, on: :select_special_applicator_type, if: :other_special_applicator?

  validates :frame_formulation, presence: true, on: :select_frame_formulation
  validate :frame_formulation_must_match_categories, on: :select_frame_formulation

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

  validates :exposure_condition, presence: {
    on: :add_exposure_condition,
    message: lambda do |object, _|
      I18n.t(:missing, scope: %i[activerecord errors models component attributes exposure_condition], component_name: object.component_name)
    end,
  }
  validates :exposure_routes, presence: true, on: :add_exposure_routes

  enum exposure_condition: {
    rinse_off: "rinse_off",
    leave_on: "leave_on",
  }

  before_save :remove_other_special_applicator, unless: :other_special_applicator?

  # Deletes all the associated poisonous ingredients from predefined components when
  # "contains_poisonous_ingredients" is set to "false"
  after_update :remove_poisonous_ingredients!,
               if: [:predefined?, -> { ingredients.poisonous.any? }],
               unless: :contains_poisonous_ingredients?

  aasm whiny_transitions: false, column: :state do
    state :empty, initial: true
    state :component_complete

    event :complete, after_commit: -> { notification.reload.try_to_complete_components! } do
      transitions from: :empty, to: :component_complete
    end

    event :reset_state, after_commit: -> { notification.reload.revert_to_ready_for_components! } do
      transitions from: :component_complete, to: :empty
    end
  end

  def self.exposure_routes_options
    %i[dermal oral inhalation].freeze
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

  # This method is a temporary solution for opensearch indexing, until we implement filtering by categories
  def display_sub_category
    get_category_name(sub_category)
  end

  # This method is a temporary solution for opensearch indexing, until we implement filtering by categories
  def display_sub_sub_category
    get_category_name(sub_sub_category)
  end

  # This method is a temporary solution for opensearch indexing, until we implement filtering by categories
  def display_root_category
    get_category_name(root_category)
  end

  def missing_ingredients?
    if predefined?
      contains_poisonous_ingredients? && ingredients.none?
    else
      ingredients.none?
    end
  end

  def delete_ingredient!(ingredient)
    return false unless ingredient.in?(ingredients)

    ingredient.destroy!
    if ingredients.reload.none?
      update(notification_type: nil)
      reset_state!
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

  def update_state(state)
    update(state:)
  end

  def update_formulation_type(type)
    old_type = notification_type
    self.notification_type = type
    transaction do
      return unless save(context: :select_formulation_type)

      # Purge formulation files added in old flow.
      # Now ingredients need to be added manually or use a predefined formulation.
      formulation_file.purge

      if old_type != notification_type
        ingredients.destroy_all
        reset_state!
      end
      update!(frame_formulation: nil, contains_poisonous_ingredients: nil) unless predefined?
    end
  end

  def frame_formulation?
    predefined?
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
      errors.add(:maximum_ph, "The maximum pH cannot be greater than 1 above the minimum pH")
    end
  end

  def frame_formulation_must_match_categories
    if FrameFormulations::CATEGORIES[root_category.to_s][sub_category.to_s][sub_sub_category.to_s].exclude?(frame_formulation)
      errors.add(:frame_formulation, "The chosen frame formulation must match the category of the product")
    end
  end

  def remove_poisonous_ingredients!
    ingredients.poisonous.destroy_all
  end
end
