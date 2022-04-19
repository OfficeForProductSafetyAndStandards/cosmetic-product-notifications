module NotificationWizard
  class DeleteComponentForm < Form
    attribute :component_id
    attribute :notification

    validates :component_id, presence: true

    def delete
      return false unless valid?
      raise("Can not remove item") if notification.components.count < 3
      raise ActiveRecord::RecordNotFound if notification.notification_complete? || notification.deleted?

      notification.components.find(component_id).destroy
      notification.try_to_complete_components!
      true
    end
  end
end
