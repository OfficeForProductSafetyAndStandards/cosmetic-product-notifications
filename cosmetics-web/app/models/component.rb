class Component < ApplicationRecord
  belongs_to :notification

  before_save :update_notification_state

  def update_notification_state
      notification.set_single_or_multi_component!
  end
end
