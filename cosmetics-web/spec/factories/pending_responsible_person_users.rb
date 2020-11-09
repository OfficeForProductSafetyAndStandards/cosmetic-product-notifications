FactoryBot.define do
  factory :pending_responsible_person_user do
    sequence(:email_address) { |n| "pending#{n}@example.com" }
    association :responsible_person, factory: :responsible_person
    association :inviting_user, factory: :submit_user

    trait :expired do
      # rubocop:disable Rails/SkipsModelValidations
      after(:create) do |obj|
        obj.update_attribute(:invitation_token_expires_at, 1.second.ago)
      end
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
