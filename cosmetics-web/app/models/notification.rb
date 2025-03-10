class Notification < ApplicationRecord
  class DeletionPeriodExpired < ArgumentError; end

  DELETION_PERIOD_DAYS = 7
  DELETABLE_ATTRIBUTES = %w[
    product_name
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
    csv_cache
  ].freeze

  CLONABLE_ATTRIBUTES = %i[
    import_country
    responsible_person_id
    shades
    industry_reference
    still_on_the_market
    components_are_mixed
    ph_min_value
    ph_max_value
    routing_questions_answers
  ].freeze

  MAXIMUM_IMAGE_UPLOADS = 10

  include Searchable
  include RoutingQuestionCacheConcern
  include Clonable
  include NotificationStateConcern

  # Don't install callbacks for paper_trail since we save versions manually on some AASM state changes
  has_paper_trail on: []

  belongs_to :responsible_person

  has_many :components, dependent: :destroy
  has_many :nano_materials, dependent: :destroy
  has_many :image_uploads, dependent: :destroy

  has_one :deleted_notification, dependent: :destroy
  has_one :source_notification, class_name: "Notification", foreign_key: :source_notification_id

  accepts_nested_attributes_for :image_uploads

  # This is an ElasticSearch alias, not the actual index name.
  # Current version of the index name is accessible through Notification.current_index.
  index_name [ENV.fetch("OS_NAMESPACE", "default_namespace"), Rails.env, "notifications"].join("_")

  scope :opensearch, -> { where(state: %i[notification_complete archived]) }
  scope :completed, -> { where(state: :notification_complete) }
  scope :archived, -> { where(state: :archived) }

  before_create do
    new_reference_number = nil
    loop do
      new_reference_number = SecureRandom.rand(100_000_000)
      break unless Notification.where(reference_number: new_reference_number).exists?
    end
    self.reference_number = new_reference_number if reference_number.nil?
  end

  before_save :add_product_name, if: :will_save_change_to_product_name?

  after_destroy :delete_document_from_index, unless: :deleted?

  def self.duplicate_notification_message
    "Notification duplicated"
  end

  validate :all_required_attributes_must_be_set
  validates :cpnp_reference, uniqueness: { scope: :responsible_person, message: duplicate_notification_message },
                             allow_nil: true
  validates :industry_reference, presence: { on: :add_internal_reference, message: "Enter an internal reference" }
  validates :under_three_years, inclusion: { in: [true, false] }, on: :for_children_under_three
  validates :components_are_mixed, inclusion: { in: [true, false] }, on: :is_mixed
  validates :ph_min_value, :ph_max_value, presence: true, on: :ph_range
  validates :ph_min_value, :ph_max_value, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 14 }, allow_nil: true

  validate :max_ph_is_greater_than_min_ph
  validate :difference_between_maximum_and_minimum_ph, on: :ph_range

  validates_with AcceptAndSubmitValidator, on: :accept_and_submit

  validates :archive_reason, presence: { on: :archive, message: "A reason for archiving must be selected" }

  delegate :count, to: :components, prefix: true

  enum archive_reason: {
    product_no_longer_available_on_the_market: "product_no_longer_available_on_the_market",
    product_no_longer_manufactured: "product_no_longer_manufactured",
    change_of_responsible_person: "change_of_responsible_person",
    change_of_manufacturer: "change_of_manufacturer",
    significant_change_to_the_formulation: "significant_change_to_the_formulation",
    product_notified_but_did_not_get_placed_on_the_market: "product_notified_but_did_not_get_placed_on_the_market",
    error_in_the_notification: "error_in_the_notification",
  }

  settings do
    mapping do
      indexes :product_name, type: "text"
      indexes :reference_number, type: "text"
      indexes :industry_reference, type: "text"
      indexes :reference_number_for_display, type: "text"
      indexes :searchable_ingredients, type: "text"
      indexes :created_at, type: "date"
      indexes :notification_complete_at, type: "date", format: "strict_date_optional_time"
      indexes :state, type: "text"

      indexes :responsible_person do
        indexes :name, type: "text"
        indexes :id, type: "integer"
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
      only: %i[product_name notification_complete_at reference_number industry_reference state],
      methods: %i[reference_number_for_display searchable_ingredients],
      include: {
        responsible_person: {
          only: %i[id name address_line_1 address_line_2 city county postal_code],
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
      ingredients << c.ingredients.pluck(:inci_name)
    end

    ingredients.flatten.join(",")
  end

  def reference_number_for_display
    return "" if reference_number.blank?

    sprintf("UKCP-%08d", reference_number)
  end

  def add_image(image)
    validate_image(image)

    return unless errors.empty?

    image_uploads.build.tap do |upload|
      upload.file.attach(image)
      upload.filename = image.original_filename

      errors.add(:image_uploads, :virus_detected, message: "The selected file contains a virus") if upload.failed_antivirus_check?
      upload.file.purge unless errors.empty?
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

  def is_multicomponent?
    components.length > 1
  end

  def multi_component?
    is_multicomponent?
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
      count.times { nano_materials.create! }
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
  # particular cases arise, eg. we need to completely remove a Responsible Person and
  # its associated notifications.
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
  #
  # A deleted notification can be recovered by calling `recover!` on `DeletedNotification`.

  # Keeps the original "ActiveRecord::Persistence#destroy" behaviour as "#hard_delete!"
  # This allows to still hard delete notifications after "#destroy" is overwritten
  # to do a soft deletion.
  alias_method :hard_delete!, :destroy

  # Soft deletion of a notification implies:
  # - Sets notification state as "deleted"
  # - Creates an associated "deleted_notification" object containing the notification information.
  # - Removes information from original notification object that has been "deleted".
  # - Removes document from OpenSearch index if it was previously added.
  def soft_delete!
    return if deleted?

    needs_index_deletion = notification_complete?
    transaction do
      DeletedNotification.create!(attributes.slice(*DELETABLE_ATTRIBUTES).merge(notification: self, state:))
      DELETABLE_ATTRIBUTES.each do |field|
        self[field] = nil
      end
      self.deleted_at = Time.zone.now
      self.state = DELETED
      self.paper_trail_event = "delete"
      self.paper_trail.save_with_version(validate: false) # rubocop:disable Style/RedundantSelf

      delete_document_from_index if needs_index_deletion
    end
  end

  alias_method :destroy, :soft_delete!
  alias_method :destroy!, :soft_delete!

  def delete!
    raise "Not supported"
  end

  alias_method :delete, :delete!

  def can_be_deleted?
    !archived? && (!notification_complete? || notification_complete_at > Notification::DELETION_PERIOD_DAYS.days.ago)
  end

  def cache_notification_for_csv!
    self.csv_cache = NotificationDecorator.new(self).to_csv
    save!
  end

  def cloned?
    source_notification.present?
  end

  def editable?
    EDITABLE_STATES.include? state.to_sym
  end

  def versions_with_name
    PaperTrail::Version
      .where(item: self)
      .joins("LEFT JOIN users ON users.id::text = versions.whodunnit")
      .order(created_at: :asc)
      .order(id: :asc)
      .select("versions.*, COALESCE(users.name, 'Unknown') AS whodunnit, users.type as user_type")
  end

private

  def all_required_attributes_must_be_set
    mandatory_attributes = mandatory_attributes(state) || []

    (changed || []).each do |attribute|
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
    when "archived"
      mandatory_attributes("draft_complete")
    end
  end

  def max_ph_is_greater_than_min_ph
    if ph_min_value.present? && ph_max_value.present? && ph_min_value > ph_max_value
      errors.add :ph_range, "The minimum pH must be lower than the maximum pH"
    end
  end

  def difference_between_maximum_and_minimum_ph
    return unless ph_min_value.present? && ph_max_value.present?

    if (ph_max_value - ph_min_value).round(2) > 1.0
      errors.add(:ph_max_value, "The maximum pH cannot be greater than 1 above the minimum pH")
    end
  end

  def validate_image(image)
    # We need to use `length` here rather than `count` since we're potentially adding multiple
    # image uploads before saving the notification, and `count` will only tell us what's already
    # in the database.
    errors.add(:image_uploads, :too_long, message: "You can only upload up to #{MAXIMUM_IMAGE_UPLOADS} images") unless image_uploads.length < MAXIMUM_IMAGE_UPLOADS
    errors.add(:image_uploads, :bad_file_extension, message: "The selected file must be a JPG, PNG or PDF") unless ImageUpload.allowed_types.include?(image.content_type)
    errors.add(:image_uploads, :too_large, message: "The selected file must be smaller than 30MB") unless image.tempfile.size <= ImageUpload.max_file_size
  end
end

# for auto sync model with Opensearch
if Rails.env.development? && ENV["DISABLE_LOCAL_AUTOINDEX"].blank?
  Notification.import_to_opensearch force: true
end
