class Notification < ApplicationRecord
  class DeletionPeriodExpired < ArgumentError; end
  include NotificationStateConcern

  DELETION_PERIOD_DAYS = 7
  DELETABLE_ATTRIBUTES = %w[product_name
                            import_country
                            reference_number
                            cpnp_reference
                            shades
                            industry_reference
                            cpnp_notification_date
                            was_notified_before_eu_exit
                            under_three_years
                            still_on_the_market
                            components_are_mixed
                            ph_min_value
                            ph_max_value
                            notification_complete_at
                            csv_cache].freeze

  include Searchable
  include CountriesHelper
  include RoutingQuestionCacheConcern

  belongs_to :responsible_person

  has_many :components, dependent: :destroy
  has_many :nano_materials, dependent: :destroy
  has_many :image_uploads, dependent: :destroy

  has_one :deleted_notification, dependent: :destroy

  accepts_nested_attributes_for :image_uploads

  index_name [ENV.fetch("OS_NAMESPACE", "default_namespace"), Rails.env, "notifications"].join("_")
  scope :opensearch, -> { where(state: "notification_complete") }

  before_create do
    new_reference_number = nil
    loop do
      new_reference_number = SecureRandom.rand(100_000_000)
      break unless Notification.where(reference_number: new_reference_number).exists?
    end
    self.reference_number = new_reference_number if reference_number.nil?
  end

  before_save :add_product_name, if: :will_save_change_to_product_name?

  def self.duplicate_notification_message
    "Notification duplicated"
  end

  def self.completed
    where(state: :notification_complete)
  end

  validate :all_required_attributes_must_be_set
  validates :cpnp_reference, uniqueness: { scope: :responsible_person, message: duplicate_notification_message },
                             allow_nil: true
  validates :industry_reference, presence: { on: :add_internal_reference, message: "Enter an internal reference" }
  validates :under_three_years, inclusion: { in: [true, false] }, on: :for_children_under_three
  validates :components_are_mixed, inclusion: { in: [true, false] }, on: :is_mixed
  validates :ph_min_value, :ph_max_value, presence: true, on: :ph_range
  validates :ph_min_value, :ph_max_value, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 14 },
                                          allow_nil: true
  validate :max_ph_is_greater_than_min_ph

  validates_with AcceptAndSubmitValidator, on: :accept_and_submit

  delegate :count, to: :components, prefix: true

  settings do
    mapping do
      indexes :product_name, type: "text"
      indexes :reference_number, type: "text"
      indexes :reference_number_for_display, type: "text"
      indexes :searchable_ingredients, type: "text"
      indexes :created_at, type: "date"
      indexes :notification_complete_at, type: "date", format: "strict_date_optional_time"

      indexes :responsible_person do
        indexes :name, type: "text"
        indexes :address_line_1, type: "text"
        indexes :address_line_2, type: "text"
        indexes :city, type: "text"
        indexes :county, type: "text"
        indexes :postal_code, type: "text"
      end

      indexes :components, type: "nested" do
        indexes :display_sub_category, type: "text"
        indexes :display_sub_sub_category, type: "text"
        indexes :display_root_category, type: "keyword"
      end
    end
  end

  def as_indexed_json(*)
    as_json(
      only: %i[product_name notification_complete_at reference_number],
      methods: %i[reference_number_for_display searchable_ingredients],
      include: {
        responsible_person: {
          only: %i[name address_line_1 address_line_2 city county postal_code],
        },
        components: {
          methods: %i[display_sub_category display_sub_sub_category display_root_category],
        },
      },
    )
  end

  def searchable_ingredients
    ingredients = []
    components.each do |c|
      c.exact_formulas.each do |f|
        ingredients << f.inci_name
      end
    end

    ingredients.join(",")
  end

  def reference_number_for_display
    return "" if reference_number.blank?

    sprintf("UKCP-%08d", reference_number)
  end

  def add_image(image)
    image_uploads.build.tap do |upload|
      upload.file.attach(image)
      upload.filename = image.original_filename
    end
  end

  def to_param
    reference_number.to_s
  end

  def missing_nano_materials
    # return nano_material that is in the notification, but not in the component
    notification_nano_ids = nano_materials.pluck(:id).sort
    components_nano_ids = components.map(&:nano_materials).flatten.map(&:id).sort
    ids = notification_nano_ids - components_nano_ids
    ids.map { |id| nano_materials.find(id) }
  end

  def formulation_required?
    components.any?(&:formulation_required?)
  end

  def formulation_present?
    components.none?(&:formulation_required?)
  end

  def is_multicomponent?
    components.length > 1
  end

  def multi_component?
    is_multicomponent?
  end

  def single_component?
    !multi_component?
  end

  def get_valid_multicomponents
    components.select(&:is_valid_multicomponent?)
  end

  def get_invalid_multicomponents
    components - get_valid_multicomponents
  end

  # Returns true if the notification was notified via uploading
  # a ZIP file (eg from CPNP).
  def via_zip_file?
    cpnp_reference.present?
  end

  # Sets up a given count of nanomaterials for the notification.
  # Nothing to do if notification already contains nanomaterials.
  # Returns number of nano materials added to the notification
  def make_ready_for_nanomaterials!(count)
    count = count.to_i
    return 0 unless count.positive? && nano_materials.none?

    transaction do
      count.times do
        nano_materials.create.tap do |nano|
          nano.nano_elements.create!
        end
      end
      revert_to_ready_for_nanomaterials
    end
    count
  end

  # Sets up a single component notification or prepares it for the upgrade to multicomponent notification.
  # Nothing to do if notification is already multicomponent.
  # Returns number of components added to the notification.
  def make_single_ready_for_components!(count)
    return 0 if multi_component? || count.negative?

    transaction do
      if count > 1 # Turning into a multi component notification
        reset_previous_state! # Previous state was set to prevent messing state when nanos are added
        revert_to_details_complete
      end

      count += 1 if count.zero? # Single component notification
      count -= 1 if components.one? # Don't create the already existing component
      count.times { components.create! }
    end
    count
  end

  # =========================================
  # DELETING NOTIFICATIONS
  # =========================================
  #
  # Notifications will be soft deleted by default. We want to avoid hard deletes unless
  # particular cases arise.
  # EG: We need to completely remove a Responsible Person and its associated notifications.
  #
  # The following code overwrites ActiveRecord methods to default to soft deletion.
  # - Notification will be soft deleted when calling:
  #   - soft_delete!
  #   - destroy
  #   - destroy!
  # - Notification will be hard deleted when calling:
  #   - hard_delete!
  # - Disabled methods:
  #   - delete
  #   - delete!

  # Keeps the original "ActiveRecord::Persistence#destroy" behaviour as "#hard_delete!"
  # This sllows to still hard delete notifications after "#destroy" is overwritten
  # to do a soft deletion.
  alias_method :hard_delete!, :destroy

  # Soft deletion of a notification implies:
  # - Set notification state as "deleted"
  # - Creates an associated "deleted_notification" object containing the notification information.
  # - Removes information from original notification object that has been "deleted".
  def soft_delete!
    return if deleted?

    transaction do
      DeletedNotification.create!(attributes.slice(*DELETABLE_ATTRIBUTES).merge(notification: self, state: state))
      DELETABLE_ATTRIBUTES.each do |field|
        self[field] = nil
      end

      self.deleted_at = Time.zone.now
      self.state = :deleted

      save!(validate: false)
    end
  end

  alias_method :destroy, :soft_delete!
  alias_method :destroy!, :soft_delete!

  def delete!
    raise "Not supported"
  end

  alias_method :delete, :delete!

  def can_be_deleted?
    !notification_complete? || notification_complete_at > Notification::DELETION_PERIOD_DAYS.days.ago
  end

  def cache_notification_for_csv!
    self.csv_cache = NotificationDecorator.new(self).to_csv
    save!
  end

private

  def all_required_attributes_must_be_set
    mandatory_attributes = mandatory_attributes(state)

    changed.each do |attribute|
      if mandatory_attributes.include?(attribute) && self[attribute].blank?
        if attribute == "product_name"
          errors.add attribute, "Enter the product name"
        else
          errors.add attribute, "Must not be empty"
        end
      end
    end
  end

  def mandatory_attributes(state)
    case state
    when "empty"
      %w[product_name]
    when "product_name_added"
      mandatory_attributes("empty")
    when "details_complete"
      mandatory_attributes("empty")
    when "ready_for_nanomaterials"
      mandatory_attributes("empty")
    when "ready_for_components"
      mandatory_attributes("empty")
    when "import_country_added"
      %w[components] + mandatory_attributes("product_name_added")
    when "components_complete"
      mandatory_attributes("import_country_added")
    when "draft_complete"
      mandatory_attributes("components_complete")
    when "deleted"
      mandatory_attributes("components_complete")
    when "notification_complete"
      mandatory_attributes("draft_complete")
    end
  end

  def max_ph_is_greater_than_min_ph
    if ph_min_value.present? && ph_max_value.present? && ph_min_value > ph_max_value
      errors.add :ph_range, "The minimum pH must be lower than the maximum pH"
    end
  end
end

# Notification.opensearch.import force: true if Rails.env.development? # for auto sync model with Opensearch
