FactoryBot.define do
  factory :user do
    transient do
      first_login { false }
    end

    id { SecureRandom.uuid }
    first_name { "Test User" }
    email { "test.user@example.com" }

    after :build do |user, options|
      create(:user_attributes, user: user, declaration_accepted: !options.first_login)
    end
  end
end
