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

    trait :with_a_previous_address do
      after(:create) do |responsible_person|
        create(:responsible_person_address_log, responsible_person:)
        responsible_person.reload
      end
    end

    trait :with_previous_addresses do
      after(:create) do |responsible_person|
        build_list(:responsible_person_address_log, 2, responsible_person:) do |record, i|
          record.start_date = (i + 1).days.ago.beginning_of_day
          record.end_date = i.days.ago.end_of_day
          record.save!
        end
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
