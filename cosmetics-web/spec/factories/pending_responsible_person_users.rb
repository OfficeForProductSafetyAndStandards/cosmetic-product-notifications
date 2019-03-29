FactoryBot.define do
  factory :pending_responsible_person_user do
    email_address { "user@example.com" }
    responsible_person { nil }
    after(:create) do |pending_responsible_person_user|
      pending_responsible_person_user.expires_at = 2.days.from_now
    end

    factory :expired_pending_responsible_person_user do
      after(:create) do |pending_responsible_person_user|
        pending_responsible_person_user.expires_at = 4.days.ago
      end
    end
  end
end
