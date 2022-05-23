class AcceptAndSubmitValidator < ActiveModel::Validator
  def validate(notification)
    validate_nano_materials(notification)
    validate_image_uploads(notification)
    validate_frame_formulation_uploads(notification)
  end

  def validate_nano_materials(notification)
    missing_nano_materials = notification.missing_nano_materials
    if missing_nano_materials.present?
      missing_nano_materials.each do |nano|
        notification.errors.add :nano_materials, "#{nano.name} is not included in any items"
      end
    end
  end

  def validate_image_uploads(notification)
    notification.image_uploads.each do |image_upload|
      if image_upload.pending_antivirus_check?
        notification.errors.add :image_uploads, "Image #{image_upload.file.filename} is still being processed"
      elsif image_upload.failed_antivirus_check?
        notification.errors.add :image_uploads, "Image #{image_upload.file.filename} failed antivirus check. Remove image and try again"
      end
    end
    if notification.image_uploads.blank?
      notification.errors.add :image_uploads, "Product image is missing"
    end
  end

  def validate_frame_formulation_uploads(notification)
    notification.components.each do |component|
      if component.formulation_file_required?
        notification.errors.add :formulation_uploads, "Item #{component.name} is missing formulation file"
      elsif component.formulation_file_pending_antivirus_check?
        notification.errors.add :formulation_uploads, "File #{component.formulation_file.filename} is still being processed"
      elsif component.formulation_file_failed_antivirus_check?
        notification.errors.add :formulation_uploads, "File #{component.formulation_file.filename} failed antivirus check. Remove file and try again"
      end
    end
  end
end
