FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "John Doe#{n}" }
    sequence(:email) { |n| "john.doe#{n}@example.org" }
    password { "testpassword123" }
    has_accepted_declaration { true }
    account_security_completed { true }
    with_all_secondary_authentication_methods

    trait :with_all_secondary_authentication_methods do
      with_app_secondary_authentication
      with_sms_secondary_authentication
      secondary_authentication_methods { %w[app sms] }
    end

    trait :with_app_secondary_authentication do
      last_totp_at { 1_432_703_530 }
      totp_secret_key { ROTP::Base32.random }
      secondary_authentication_methods { %w[app] }
    end

    trait :with_sms_secondary_authentication do
      mobile_number { "07500 000 000" }
      mobile_number_verified { true }
      direct_otp_sent_at { Time.zone.now }
      direct_otp { "12345" }
      secondary_authentication_methods { %w[sms] }
    end

    trait :without_secondary_authentication do
      last_totp_at { nil }
      totp_secret_key { nil }
      mobile_number { nil }
      mobile_number_verified { false }
      direct_otp_sent_at { nil }
      direct_otp { nil }
      secondary_authentication_methods { nil }
      account_security_completed { false }
    end

    trait :invited do
      invite { true }
    end

    factory :submit_user, class: "SubmitUser" do
      confirmed_at { 1.hour.ago }

      trait :with_responsible_person do
        after(:create) do |user|
          create_list(:responsible_person_user, 1, user: user)
        end
      end

      trait :confirmed_not_verified do
        without_secondary_authentication
        confirmed_at { 1.hour.ago }
        confirmation_sent_at { Time.zone.now }
        confirmation_token { Devise.friendly_token }
      end

      trait :unconfirmed do
        without_secondary_authentication
        password { nil }
        confirmed_at { nil }
        confirmation_sent_at { Time.zone.now }
        confirmation_token { Devise.friendly_token }
        account_security_completed { false }
        to_create { |user| user.save(validate: false) }
      end
    end

    factory :search_user, class: "SearchUser" do
      role {}
      invitation_token { Devise.friendly_token }
      invited_at { Time.zone.now }

      transient do
        first_login { false }
      end

      factory :poison_centre_user do
        role { :poison_centre }
      end

      factory :msa_user do
        role { :msa }
      end

      after :create do |user, options|
        create(:user_attributes, user: user, declaration_accepted: !options.first_login)
      end

      trait :registration_incomplete do
        without_secondary_authentication
        password { nil }
        account_security_completed { false }
        to_create { |user| user.save(validate: false) }
      end
    end
  end
end
