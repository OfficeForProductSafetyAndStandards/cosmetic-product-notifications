class Notification < ApplicationRecord
  include AASM

  before_save :add_product_name, if: :will_save_change_to_product_name?
  before_save :add_external_reference, if: :will_save_change_to_external_reference?

  validate :all_required_attributes_must_be_set

  aasm whiny_transitions: false, column: :state do
    state :empty, initial: true
    state :product_name_added
    state :draft_complete
    state :notification_complete

    event :add_product_name do
      transitions from: :empty, to: :product_name_added
    end

    event :add_external_reference do
      transitions from: :product_name_added, to: :draft_complete
    end

    event :submit_notification do
      transitions from: :draft_complete, to: :notification_complete
    end
  end

  private

  def all_required_attributes_must_be_set
    mandatory_attributes = mandatory_attributes(state)

    changed.select { |attribute| 
      mandatory_attributes.include?(attribute) && self[attribute].blank?
    }.each { |attribute|
      errors.add attribute, "must not be blank"
    }
  end

  def mandatory_attributes(state)
    case state
    when 'empty'
      return %w[product_name]
    when 'product_name_added'
      return %w[external_reference] + mandatory_attributes('empty')
    when 'external_reference_added'
      return mandatory_attributes('product_name_added')
    when 'draft_complete'
      return mandatory_attributes('external_reference_added')
    when 'notification_complete'
      return mandatory_attributes('draft_complete')
    end
  end
end
