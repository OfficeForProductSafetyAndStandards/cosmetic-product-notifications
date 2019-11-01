FactoryBot.define do
  factory :responsible_person do
    account_type { :individual }
    name { "Responsible Person" }
    address_line_1 { "Street address" }
    city { "City" }
    postal_code { "AB12 3CD" }
    contact_persons { [create(:contact_person)] }

    trait :with_no_contact_person do
      contact_persons { [] }
    end

    factory :business_responsible_person do
      account_type { :business }
    end

    factory :responsible_person_with_user do
      after(:create) do |responsible_person|
        create_list(:responsible_person_user, 1, responsible_person: responsible_person)
      end
    end
  end
end
