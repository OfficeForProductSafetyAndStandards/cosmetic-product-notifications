class AcceptAndSubmitValidator < ActiveModel::Validator
  def validate(notification)
    validate_nano_materials(notification)
    validate_image_uploads(notification)
    validate_ingredients(notification)
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
        notification.errors.add :image_uploads, "Image #{image_upload.file.filename} is pending virus scan"
      elsif image_upload.failed_antivirus_check?
        notification.errors.add :image_uploads, "Image #{image_upload.file.filename} failed virus scan; remove the image and try again"
      end
    end
    if notification.image_uploads.blank?
      notification.errors.add :image_uploads, "Product image is missing"
    end
  end

  def validate_ingredients(notification)
    notification.components.each do |component|
      if component.missing_ingredients?
        notification.errors.add :formulation_uploads, "The notification has not listed any ingredients"
      end
    end
    ingredients = notification.reload.components.map(&:ingredients).flatten
    if ingredients.any? { |i| i.inci_name.length > Ingredient::NAME_LENGTH_LIMIT }
      notification.errors.add :ingredients, "Ingredient names must be 100 characters or less"
    end
  end
end
