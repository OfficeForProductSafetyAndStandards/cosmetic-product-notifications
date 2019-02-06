class Notification < ApplicationRecord
  include AASM
  include Shared::Web::CountriesHelper

  belongs_to :responsible_person
  has_many :components, dependent: :destroy

  before_save :add_product_name, if: :will_save_change_to_product_name?
  before_save :add_import_country, if: :will_save_change_to_import_country?

  validate :all_required_attributes_must_be_set

  aasm whiny_transitions: false, column: :state do
    state :empty, initial: true
    state :product_name_added
    state :import_country_added
    state :draft_complete
    state :notification_complete

    event :add_product_name do
      transitions from: :empty, to: :product_name_added
    end

    event :add_import_country do
      transitions from: :product_name_added, to: :import_country_added
    end

    event :set_single_or_multi_component do
      transitions from: :import_country_added, to: :draft_complete
    end

    event :submit_notification do
      transitions from: :draft_complete, to: :notification_complete
    end
  end

  def import_country_for_display
    country_from_code(import_country) || import_country
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
    when 'draft_complete'
      mandatory_attributes('import_country_added')
    when 'notification_complete'
      mandatory_attributes('import_country_added')
    end
  end
end
