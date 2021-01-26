class ContactPerson < ApplicationRecord
  belongs_to :responsible_person

  validates :name, presence: true
  validates :email_address,
            presence: true,
            email: { message: :wrong_format, if: -> { email_address.present? } }
  validates :phone_number,
            presence: true,
            phone: { message: :invalid, allow_landline: true, allow_international: true, if: -> { phone_number.present? } }
end
