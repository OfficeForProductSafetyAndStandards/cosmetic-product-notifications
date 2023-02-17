class DatePresenceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    UnusedCodeAlerting.alert
    return if value.nil? || value.is_a?(Date)

    if value.day.blank? && value.month.blank? && value.year.blank?
      record.errors.add(attribute, :present)
    end
  end
end
