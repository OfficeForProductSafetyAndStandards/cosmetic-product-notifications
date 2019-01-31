class Component < ApplicationRecord
  include AASM

  belongs_to :notification

  before_save :update_notification_state
  before_save :add_shades, if: :will_save_change_to_shades?

  validates :shades, length: { 
    minimum: 2, 
    allow_nil: true, 
    message: "Shades must have at least two entries"
  }

  aasm whiny_transitions: false, column: :state do
    state :empty, initial: true
    state :component_complete

    event :add_shades do
      transitions from: :empty, to: :component_complete
    end
  end

  def prune_blank_shades
    return if self[:shades].nil?

    self[:shades] = self[:shades].select { |shade| shade.present? }
  end

private

  def update_notification_state
    notification.set_single_or_multi_component!
  end
end
