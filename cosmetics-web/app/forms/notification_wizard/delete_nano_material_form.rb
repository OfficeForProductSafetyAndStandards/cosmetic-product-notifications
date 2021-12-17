module NotificationWizard
  class DeleteNanoMaterialForm < Form
    class NonEmptyArrayValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        if value.blank? || value.reject(&:blank?).blank?
          record.errors.add attribute, "can not be blank"
        end
      end
    end

    attribute :nano_material_ids
    attribute :notification

    validates :nano_material_ids, non_empty_array: true

    def delete
      return false unless self.valid?
      raise ActiveRecord::RecordNotFound if ['notification_complete', 'deleted'].include?(notification.state)

      notification.nano_materials.find(nano_material_ids).each(&:destroy)
      notification.reload.try_to_complete_nanomaterials!
      true
    end
  end
end
