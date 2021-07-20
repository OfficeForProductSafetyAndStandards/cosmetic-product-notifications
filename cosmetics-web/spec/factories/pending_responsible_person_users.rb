FactoryBot.define do
  factory :pending_responsible_person_user do
    sequence(:email_address) { |n| "pending#{n}@example.com" }
    sequence(:name) { |n| "John Doe#{n}" }
    association :responsible_person, factory: :responsible_person
    association :inviting_user, factory: :submit_user

    trait :expired do
      after(:stub, :build) do |obj|
        obj.invitation_token_expires_at = 1.second.ago
      end

      after(:create) do |obj|
        # rubocop:disable Rails/SkipsModelValidations
        obj.update_attribute(:invitation_token_expires_at, 1.second.ago)
        # rubocop:enable Rails/SkipsModelValidations
      end
    end
  end
end
