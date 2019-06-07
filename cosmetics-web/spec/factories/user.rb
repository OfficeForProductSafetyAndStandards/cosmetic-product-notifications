FactoryBot.define do
  factory :user do
    transient do
      first_login { false }
    end

    id { SecureRandom.uuid }
    name { "Test User" }
    email { "test.user@example.com" }

    after :build do |user, options|
      create(:user_attributes, user: user, declaration_accepted: !options.first_login)
    end

    # The following users match specific test accounts on Keycloak and are used in system tests for Keycloak integration

    factory :keycloak_test_user do
      id { "dbbc495b-475e-419a-a151-2e61c6f9fdce" }
      name { "Test User" }
      email { "user@example.com" }
    end

    factory :keycloak_admin_user do
      id { "eefa13c3-a47f-4199-9dc2-1c9d36af323b" }
      name { "Team Admin" }
      email { "admin@example.com" }
    end

    factory :keycloak_msa_user do
      id { "e43bc41b-8ba6-45b0-ad45-1e4d261ac6be" }
      name { "MSA User" }
      email { "msa@example.com" }
    end

    factory :keycloak_poison_centre_user do
      id { "ece05a23-25bd-4be1-9a65-deda1dac3f8c" }
      name { "Poison Centre User" }
      email { "poison.centre@example.com" }
    end
  end
end
