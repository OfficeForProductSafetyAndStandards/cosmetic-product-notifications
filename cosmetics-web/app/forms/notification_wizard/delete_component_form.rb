module NotificationWizard
  class DeleteComponentForm < Form
    attribute :component_id
    attribute :notification

    validates :component_id, presence: true

    def delete
      return false unless valid?
      raise("Can not remove item") if notification.components.count < 3
      raise ActiveRecord::RecordNotFound if %w[notification_complete deleted].include?(notification.state)

      component = notification.components.find(component_id)
      component.destroy
      notification.try_to_complete_components!
      true
    end
  end
end
