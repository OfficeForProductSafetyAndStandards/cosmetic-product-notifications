module NotificationWizard
  class DeleteComponentForm < Form
    attribute :component_id
    attribute :notification

    validates :component_id, presence: true

    def delete
      return false unless self.valid?

      component = notification.components.find(component_id)
      component.destroy
      notification.try_to_complete_components!
      true
    end
  end
end
