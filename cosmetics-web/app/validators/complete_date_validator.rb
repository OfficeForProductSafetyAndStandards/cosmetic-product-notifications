# Validate that the date isn't missing a day, month or year
#
# This assumes that any non-complete date is something other than a Date object (which can only
# represent complete dates) and which implements day, month and year methods. For example, this
# could be a struct.
#
# The missing date parts (eg "year" or "day and month") are stored as `:missing_date_parts`
# so that they can be interpolated into the error message.
#
# If all three parts of the date are blank, then no error is added, as this can be covered
# by the `presence` validator so that a more meaningful error message is included.
#
# See https://design-system.service.gov.uk/components/date-input/#if-the-date-is-incomplete
class CompleteDateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil? || value.is_a?(Date)

    missing_date_parts = []
    missing_date_parts << "day" if value.day.blank?
    missing_date_parts << "month" if value.month.blank?
    missing_date_parts << "year" if value.year.blank?

    if missing_date_parts.size.between?(1, 2)
      record.errors.add(attribute, :incomplete, missing_date_parts: missing_date_parts.to_sentence)
    end
  end
end
