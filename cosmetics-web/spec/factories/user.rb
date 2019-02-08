FactoryBot.define do
  factory :user do
    id { SecureRandom.uuid }
    first_name { "Test User" }
    email { "test.user@example.com" }
  end
end
