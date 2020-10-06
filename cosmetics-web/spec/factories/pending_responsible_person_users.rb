FactoryBot.define do
  factory :pending_responsible_person_user do
    sequence(:email_address) { |n| "pending#{n}@example.com" }
    association :responsible_person, factory: :responsible_person
  end
end
