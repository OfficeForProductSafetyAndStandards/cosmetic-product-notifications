class ConfirmAndAcceptValidator < ActiveModel::Validator
  def validate(record)
    missing_nano_materials = record.missing_nano_materials
    if missing_nano_materials.present?
      missing_nano_materials.each do |nano|
        record.errors.add :base, "#{nano.name} is not included in any items"
      end
    end
  end
end
