FactoryBot.define do
  factory :contact_person do
    name { "Contact Person" }
    email_address { "contact.person@example.com" }
    phone_number { "01632 960123" }
    email_verified { true }
  end
end
