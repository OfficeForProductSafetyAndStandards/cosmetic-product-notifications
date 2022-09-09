FactoryBot.define do
  factory :responsible_person do
    account_type { :individual }
    sequence(:name) { |n| "Responsible Person #{n}" }
    address_line_1 { "Street address" }
    city { "City" }
    postal_code { "AB12 3CD" }

    trait :with_a_contact_person do
      after(:create) do |responsible_person|
        create(:contact_person, responsible_person:)
        responsible_person.reload
      end
    end

    factory :business_responsible_person do
      account_type { :business }
    end

    factory :responsible_person_with_user do
      after(:create) do |responsible_person|
        create_list(:responsible_person_user, 1, responsible_person:)
      end
    end
  end
end
