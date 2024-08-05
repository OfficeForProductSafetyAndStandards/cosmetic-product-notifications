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

  has_paper_trail on: []

  belongs_to :responsible_person

  has_many :components, dependent: :destroy
  has_many :nano_materials, dependent: :destroy
  has_many :image_uploads, dependent: :destroy

  has_one :deleted_notification, dependent: :destroy
  has_one :source_notification, class_name: "Notification", foreign_key: :source_notification_id

  accepts_nested_attributes_for :image_uploads

  index_name [ENV.fetch("OS_NAMESPACE", "default_namespace"), Rails.env, "notifications"].join("_")

  scope :opensearch, -> { where(state: %i[notification_complete archived]) }
  scope :completed, -> { where(state: :notification_complete) }
  scope :archived, -> { where(state: :archived) }

  before_create :generate_reference_number
  before_save :add_product_name, if: :will_save_change_to_product_name?
  after_destroy :delete_document_from_index, unless: :deleted?

  def self.duplicate_notification_message
    "Notification duplicated"
  end

  validate :all_required_attributes_must_be_set
  validates :cpnp_reference, uniqueness: { scope: :responsible_person, message: duplicate_notification_message }, allow_nil: true
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
    components.includes(:ingredients).flat_map { |c| c.ingredients.pluck(:inci_name) }.join(",")
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
    notification_nano_ids = nano_materials.pluck(:id).sort
    components_nano_ids = components.includes(:nano_materials).map(&:nano_materials).flatten.map(&:id).sort
    ids = notification_nano_ids - components_nano_ids
    ids.map { |id| nano_materials.find(id) }
  end

  def is_multicomponent?
    components.length > 1
  end

  def multi_component?
    is_multicomponent?
  end

  def via_zip_file?
    cpnp_reference.present?
  end

  def make_ready_for_nanomaterials!(count)
    count = count.to_i
    return 0 unless count.positive? && nano_materials.none?

    transaction do
      count.times { nano_materials.create! }
      revert_to_ready_for_nanomaterials
    end
    count
  end

  def make_single_ready_for_components!(count)
    return 0 if multi_component? || count.negative?

    transaction do
      if count > 1
        reset_previous_state!
        revert_to_details_complete
      end

      count += 1 if count.zero?
      count -= 1 if components.one?
      count.times { components.create! }
    end
    count
  end

  alias_method :hard_delete!, :destroy

  def soft_delete!
    return if deleted?

    needs_index_deletion = notification_complete?
    transaction do
      DeletedNotification.create!(attributes.slice(*DELETABLE_ATTRIBUTES).merge(notification: self, state:))
      DELETABLE_ATTRIBUTES.each { |field| self[field] = nil }
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

  def generate_reference_number
    self.reference_number ||= loop do
      new_reference_number = SecureRandom.rand(100_000_000)
      break new_reference_number unless Notification.exists?(reference_number: new_reference_number)
    end
  end

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
    if ph_min_value.present? && ph_max_value.present? && (ph_max_value - ph_min_value).round(2) > 1.0
      errors.add(:ph_max_value, "The maximum pH cannot be greater than 1 above the minimum pH")
    end
  end

  def validate_image(image)
    errors.add(:image_uploads, :too_long, message: "You can only upload up to #{MAXIMUM_IMAGE_UPLOADS} images") unless image_uploads.length < MAXIMUM_IMAGE_UPLOADS
    errors.add(:image_uploads, :bad_file_extension, message: "The selected file must be a JPG, PNG or PDF") unless ImageUpload.allowed_types.include?(image.content_type)
    errors.add(:image_uploads, :too_large, message: "The selected file must be smaller than 30MB") unless image.tempfile.size <= ImageUpload.max_file_size
  end
end

if Rails.env.development? && ENV["DISABLE_LOCAL_AUTOINDEX"].blank?
  Notification.import_to_opensearch force: true
end
