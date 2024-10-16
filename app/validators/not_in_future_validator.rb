class NotInFutureValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.is_a?(Date) && value > Time.zone.today
      record.errors.add(attribute, :in_future)
    end
  end
end
