class ContactPerson < ApplicationRecord
  NAME_MAX_LENGTH = 50

  belongs_to :responsible_person

  validates :name, presence: true
  validates :name, length: { maximum: NAME_MAX_LENGTH }, name_format: true, if: :name_changed?
  validates :email_address,
            presence: true,
            email: { message: :wrong_format, if: -> { email_address.present? } }
  validates :phone_number,
            presence: true,
            phone: { message: :invalid, allow_landline: true, allow_international: true, if: -> { phone_number.present? } }
end
