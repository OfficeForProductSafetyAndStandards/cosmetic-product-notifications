require_relative 'validators/manual_notification_validator'

class Notification < ApplicationRecord
  include AASM

  after_save :add_product_name!, if: :saved_change_to_product_name?
  after_save :add_external_reference!, if: :saved_change_to_external_reference?

  validates_with Validators::ManualNotificationValidator

  aasm whiny_transitions: false do
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
end
