class Notification < ApplicationRecord
  class DeletionPeriodExpired < ArgumentError; end
  include NotificationStateConcern

  DELETION_PERIOD_DAYS = 7

  include Searchable
  include CountriesHelper

  belongs_to :responsible_person

  has_many :components, dependent: :destroy
  has_many :nano_materials, dependent: :destroy
  has_many :image_uploads, dependent: :destroy

  has_one :deleted_notification

  accepts_nested_attributes_for :image_uploads

  index_name [ENV.fetch("ES_NAMESPACE", "default_namespace"), Rails.env, "notifications"].join("_")
  scope :elasticsearch, -> { where(state: "notification_complete") }

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

  settings do
    mapping do
      indexes :product_name, type: "text"
      indexes :reference_number, type: "text"
      indexes :reference_number_for_display, type: "text"
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
      methods: :reference_number_for_display,
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

  def notification_product_wizard_completed?
    !['empty', 'product_name_added'].include?(state)
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
    nano_material_required? || formulation_required? || images_missing_or_not_passed_antivirus_check?
  end

  def nano_material_required?
    false # TODO: find if we need it in new wizard
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

  # If any image is waiting for the antivirus check or it got a virus alert this method will be "true"
  def images_missing_or_not_passed_antivirus_check?
    image_uploads.empty? || !all_images_passed_anti_virus_check?
  end

  # Only will return "true" when there are no images or any image got an explicit antivirus alert
  def images_missing_or_with_virus?
    image_uploads.empty? || images_failed_anti_virus_check?
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

  def destroy_notification!(submit_user)
    if notification_complete?
      NotificationDeleteService.new(self, submit_user).call
    else
      destroy!
    end
  end

  def destroy
    destroy!
  end

  def destroy!
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

  def delete
    raise "Not supported"
  end

  def delete!
    raise "Not supported"
  end

  def can_be_deleted?
    !notification_complete? || notification_complete_at > Notification::DELETION_PERIOD_DAYS.days.ago
  end

  delegate :count, to: :components, prefix: true

  def cache_notification_for_csv!
    self.csv_cache = NotificationDecorator.new(self).to_csv
    save!
  end

  def remember_answer(hash)
    answers = self.routing_questions_answers || {}
    self.routing_questions_answers = answers.merge(hash)
    self.save
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
    when "product_name_added"
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

Notification.elasticsearch.import force: true if Rails.env.development? # for auto sync model with elastic search
