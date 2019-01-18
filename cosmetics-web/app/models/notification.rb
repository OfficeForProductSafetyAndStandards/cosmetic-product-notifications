require_relative 'validators/manual_notification_validator'

class Notification < ApplicationRecord
  include AASM

  enum state: %i[
    empty
    product_name_added
    draft_complete
    notification_complete
  ]

  before_save :add_product_name!, if: :will_save_change_to_product_name?
  before_save :add_external_reference!, if: :will_save_change_to_external_reference?

  validates_with Validators::ManualNotificationValidator

  aasm whiny_transitions: false, column: :state, enum: true do
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
