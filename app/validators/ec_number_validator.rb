class EcNumberValidator < ActiveModel::Validator
  def validate(record)
    return if record.ec_number.blank?

    unless /\A(\d{3})-?(\d{3})-?(\d)\z/.match?(record.ec_number)
      record.errors.add(:ec_number, "EC number is invalid")
    end

    unless record.ec_number.delete("^0-9").length == 7
      record.errors.add(:ec_number, "EC number must contain 7 digits")
    end
  end
end
