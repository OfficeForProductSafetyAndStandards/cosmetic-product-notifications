FactoryBot.define do
  factory :responsible_person_address_log do
    responsible_person
    line_1 { Faker::Address.street_name }
    line_2 { Faker::Address.street_address }
    city { Faker::Address.city }
    county { Faker::Address.state }
    postal_code { Faker::Address.postcode }
    start_date { "2021-10-08 17:11:23" }
    end_date { "2021-11-03 13:16:38" }
  end
end
