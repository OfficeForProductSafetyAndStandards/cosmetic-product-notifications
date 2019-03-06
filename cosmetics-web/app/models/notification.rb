class Notification < ApplicationRecord
  include Searchable

  index_name [Rails.env, "notifications"].join("_")
  include AASM
  include Shared::Web::CountriesHelper

  belongs_to :responsible_person
  has_many :components, dependent: :destroy
  has_many :image_uploads, dependent: :destroy

  accepts_nested_attributes_for :image_uploads

  before_create do
    new_reference_number = nil
    loop do
      new_reference_number = SecureRandom.rand(100000000)
      break unless Notification.where(reference_number: new_reference_number).exists?
    end
    self.reference_number = new_reference_number
  end

  before_save :add_product_name, if: :will_save_change_to_product_name?
  before_save :add_import_country, if: :will_save_change_to_import_country?

  def self.duplicate_notification_message
    "Notification duplicated"
  end

  validate :all_required_attributes_must_be_set
  validates :cpnp_reference, uniqueness: { scope: :responsible_person, message: duplicate_notification_message },
            allow_nil: true

  settings do
    mappings do
      indexes :state, type: :keyword
    end
  end

  def as_indexed_json(*)
    return { state: state } unless state == "notification_complete"

    as_json(
      only: %i[product_name state],
      include: {
        responsible_person: {
          only: %i[name]
        }
      }
    )
  end

  # rubocop:disable Metrics/BlockLength
  aasm whiny_transitions: false, column: :state do
    state :empty, initial: true
    state :product_name_added
    state :import_country_added
    state :components_complete
    state :draft_complete
    state :notification_file_imported
    state :notification_complete

    event :add_product_name do
      transitions from: :empty, to: :product_name_added
    end

    event :add_import_country do
      transitions from: :product_name_added, to: :import_country_added
    end

    event :set_single_or_multi_component do
      transitions from: :import_country_added, to: :components_complete
    end

    event :add_product_image do
      transitions from: :components_complete, to: :draft_complete
    end

    event :notification_file_parsed do
      transitions from: :empty, to: :notification_file_imported
    end

    event :submit_notification do
      transitions from: :draft_complete, to: :notification_complete, guard: :images_are_present_and_safe?
      # TODO COSBETA-26 Implement full transition logic for imported files (including formulation upload)
      transitions from: :notification_file_imported, to: :notification_complete
    end
  end
  # rubocop:enable Metrics/BlockLength

  def reference_number_for_display
    "UKCP-%08d" % reference_number
  end

  def images_are_present_and_safe?
    !image_uploads.empty? && image_uploads.all?(&:marked_as_safe?)
  end

  def images_failed_anti_virus_check?
    image_uploads.any?(&:file_missing?)
  end

  def images_pending_anti_virus_check?
    image_uploads.any? { |image|
      image.file_exists? && !image.marked_as_safe?
    }
  end

  def to_param
    reference_number.to_s
  end

private

  def all_required_attributes_must_be_set
    mandatory_attributes = mandatory_attributes(state)

    changed.each { |attribute|
      if mandatory_attributes.include?(attribute) && self[attribute].blank?
        errors.add attribute, "must not be blank"
      end
    }
  end

  def mandatory_attributes(state)
    case state
    when 'empty'
      %w[product_name]
    when 'product_name_added'
      mandatory_attributes('empty')
    when 'import_country_added'
      %w[components] + mandatory_attributes('product_name_added')
    when 'components_complete'
      mandatory_attributes('import_country_added')
    when 'draft_complete'
      mandatory_attributes('components_complete')
    when 'notification_complete'
      mandatory_attributes('draft_complete')
    when 'notification_file_imported'
      mandatory_attributes('empty')
    end
  end
end

Notification.import force: true if Rails.env.development? # for auto sync model with elastic search
