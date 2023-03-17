module ResponsiblePersons::Notifications
  class DeleteNanoMaterialForm < Form
    class NonEmptyArrayValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        if value.blank? || value.reject(&:blank?).empty?
          record.errors.add attribute, "Please select nanomaterial to remove"
        end
      end
    end

    attribute :nano_material_ids
    attribute :notification

    validates :nano_material_ids, non_empty_array: true

    def delete
      return false unless valid?
      raise ActiveRecord::RecordNotFound if notification.notification_complete? || notification.archived? || notification.deleted?

      notification.nano_materials.find(nano_material_ids).each(&:destroy)
      notification.reload.try_to_complete_nanomaterials!
      true
    end
  end
end
