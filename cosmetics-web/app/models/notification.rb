class Notification < ApplicationRecord
  include Searchable

  include AASM
  include CountriesHelper

  belongs_to :responsible_person

  has_many :components, dependent: :destroy
  has_many :image_uploads, dependent: :destroy

  accepts_nested_attributes_for :image_uploads

  index_name [ENV.fetch("ES_NAMESPACE", "default_namespace"), Rails.env, "notifications"].join("_")
  scope :elasticsearch, -> { where(state: "notification_complete") }

  before_create do
    new_reference_number = nil
    loop do
      new_reference_number = SecureRandom.rand(100_000_000)
      break unless Notification.where(reference_number: new_reference_number).exists?
    end
    self.reference_number = new_reference_number
  end

  before_save :add_product_name, if: :will_save_change_to_product_name?

  def self.duplicate_notification_message
    "Notification duplicated"
  end

  validate :all_required_attributes_must_be_set
  validates :cpnp_reference, uniqueness: { scope: :responsible_person, message: duplicate_notification_message },
                             allow_nil: true
  validates :cpnp_reference, presence: true, on: :file_upload
  validates :industry_reference, presence: { on: :add_internal_reference, message: "Enter an internal reference" }
  validates :under_three_years, inclusion: { in: [true, false] }, on: :for_children_under_three
  validates :components_are_mixed, inclusion: { in: [true, false] }, on: :is_mixed
  validates :ph_min_value, :ph_max_value, presence: true, on: :ph_range
  validates :ph_min_value, :ph_max_value, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 14 },
                                          allow_nil: true
  validate :max_ph_is_greater_than_min_ph

  def as_indexed_json(*)
    as_json(
      only: %i[product_name],
      include: {
        responsible_person: {
          only: %i[name],
        },
        components: {
          methods: %i[display_sub_category display_sub_sub_category display_root_category],
        },
      },
    )
  end
  aasm whiny_transitions: false, column: :state do
    state :empty, initial: true
    state :product_name_added
    state :components_complete
    state :draft_complete
    state :notification_file_imported
    state :notification_complete

    event :add_product_name do
      transitions from: :empty, to: :product_name_added
    end

    event :set_single_or_multi_component do
      transitions from: :product_name_added, to: :components_complete
    end

    event :complete_draft do
      transitions from: :components_complete, to: :draft_complete
    end

    event :notification_file_parsed do
      transitions from: :empty, to: :notification_file_imported, guard: :formulation_required?
      transitions from: :empty, to: :draft_complete
    end

    event :formulation_file_uploaded do
      transitions from: :notification_file_imported, to: :draft_complete, guard: :formulation_present?
    end

    event :submit_notification do
      transitions from: :draft_complete, to: :notification_complete,
                  after: proc { __elasticsearch__.index_document } do
        guard do
          !missing_information?
        end
      end
    end
  end

  def reference_number_for_display
    sprintf("UKCP-%08d", reference_number)
  end

  def add_image(image)
    image_uploads.build.tap do |upload|
      upload.file.attach(image)
      upload.filename = image.original_filename
    end
  end

  def all_images_passed_anti_virus_check?
    image_uploads.all?(&:passed_antivirus_check?)
  end

  def images_failed_anti_virus_check?
    image_uploads.any?(&:failed_antivirus_check?)
  end

  def images_pending_anti_virus_check?
    image_uploads.any?(&:pending_antivirus_check?)
  end

  def to_param
    reference_number.to_s
  end

  def missing_information?
    nano_material_required? || formulation_required? || required_images_missing_or_not_passed_antivirus_check?
  end

  def nano_material_required?
    components.any?(&:nano_material_required?)
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

  def was_notified_after_eu_exit?
    !was_notified_before_eu_exit?
  end

  alias_method :requires_images?, :was_notified_after_eu_exit?

  # If any image is waiting for the antivirus check or it got a virus alert this method will be "true"
  def required_images_missing_or_not_passed_antivirus_check?
    requires_images? && (image_uploads.empty? || !all_images_passed_anti_virus_check?)
  end

  # Only will return "true" when there are no images or any image got an explicit antivirus alert
  def required_images_missing_or_with_virus?
    requires_images? && (image_uploads.empty? || images_failed_anti_virus_check?)
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
    notification_file_imported? || cpnp_reference
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
    when "import_country_added"
      %w[components] + mandatory_attributes("product_name_added")
    when "components_complete"
      mandatory_attributes("import_country_added")
    when "draft_complete"
      mandatory_attributes("components_complete")
    when "notification_complete"
      mandatory_attributes("draft_complete")
    when "notification_file_imported"
      mandatory_attributes("empty")
    end
  end

  def max_ph_is_greater_than_min_ph
    if ph_min_value.present? && ph_max_value.present? && ph_min_value > ph_max_value
      errors.add :ph_range, "The minimum pH must be lower than the maximum pH"
    end
  end
end

Notification.elasticsearch.import force: true if Rails.env.development? # for auto sync model with elastic search
