class CasNumberValidator < ActiveModel::Validator
  def validate(record)
    return if record.cas_number.blank?

    unless /\A(\d{2,7})-?(\d{2})-?(\d)\z/.match?(record.cas_number)
      record.errors.add :cas_number, "CAS number is invalid"
    end

    unless record.cas_number.delete("^0-9").length.between?(5, 10)
      record.errors.add(:cas_number, "CAS number must contain between 5 to 10 digits")
    end
  end
end
