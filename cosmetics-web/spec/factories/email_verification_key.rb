FactoryBot.define do
  factory :email_verification_key do
    key { "aaaaaaaaaaa" }
    expires_at { 2.days.from_now }
    after(:create) do |email_verification_key|
      email_verification_key.key = "aaaaaaaaaaa"
      email_verification_key.expires_at = 2.days.from_now
    end

    factory :expired_email_verification_key do
      after(:create) do |email_verification_key|
        email_verification_key.key = "bbbbbbbbbbb"
        email_verification_key.expires_at = 4.days.ago
      end
    end
  end
end
