# Validate that the date is 'real', rather than a date which cannot exist (eg 2020-01-32)
#
# This assumes that any non-real date is something other than a Date object (which can only
# represent real dates) and which implements day, month and year methods. For example, this
# could be a struct.
#
# See https://design-system.service.gov.uk/components/date-input/#if-the-date-entered-can-t-be-correct
class RealDateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil? || value.is_a?(Date)
    return if value.day.blank? || value.month.blank? || value.year.blank?

    record.errors.add(attribute, :must_be_real)
  end
end
