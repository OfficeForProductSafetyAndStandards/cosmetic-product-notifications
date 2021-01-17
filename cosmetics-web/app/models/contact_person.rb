class ContactPerson < ApplicationRecord
  belongs_to :responsible_person

  validates :name, presence: true
  validates :email_address,
            email: {
              message: I18n.t(:wrong_format, scope: "contact_person.email_address"),
            }
  validates :email_address, presence: { message: I18n.t(:blank, scope: "contact_person.email_address") }
  validates :phone_number, presence: true,
                           numericality: true,
                           length: { minimum: 8, :maximum => 12 }
end
