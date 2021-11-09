FactoryBot.define do
  factory :responsible_person_previous_address do
    responsible_person
    line_1 { "FooBar Building" }
    line_2 { "33 Fake Street" }
    city { "Gotham" }
    county { "Greater Manchester" }
    postal_code { "NN17 1PB" }
    start_date { "2021-11-08 17:11:23" }
    end_date { "2021-10-03 13:16:38" }
  end
end
