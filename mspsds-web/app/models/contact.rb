class Contact < ApplicationRecord
  def summary
    [
        name,
        job_title,
        phone_number,
        email
    ].reject(&:blank?).join(", ")
  end
end
