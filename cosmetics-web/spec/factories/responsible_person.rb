FactoryBot.define do
  factory :responsible_person do
    account_type { :individual }
    name { "Responsible Person" }
    email_address  { "responsible.person@example.com" }
    phone_number  { "01632 960123" }
    address_line_1 { "Street address" }
    city { "City" }
    postal_code { "AB12 3CD" }

    factory :business_responsible_person do
      account_type { :business }
      companies_house_number { "12345678" }
    end
  end
end
