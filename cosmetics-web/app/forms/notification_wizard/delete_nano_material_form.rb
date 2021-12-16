module NotificationWizard
  class DeleteNanoMaterialForm < Form
    attribute :nano_material_id
    attribute :notification

    validates :nano_material_id, presence: true

    def delete
      return false unless self.valid?
      raise ActiveRecord::RecordNotFound if ['notification_complete', 'deleted'].include?(notification.state)

      notification.nano_materials.find(nano_material_id).destroy
    end
  end
end
