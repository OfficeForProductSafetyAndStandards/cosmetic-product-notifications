FactoryBot.define do
  factory :responsible_person do
    account_type { :individual }
    name { "Responsible Person" }
    email_address  { "responsible.person@example.com" }
    phone_number  { "01632 960123" }
  end
end
