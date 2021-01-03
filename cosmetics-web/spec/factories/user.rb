FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "John Doe#{n}" }
    sequence(:email) { |n| "john.doe#{n}@example.org" }
    mobile_number { "07500 000 000" }
    password { "testpassword123" }
    has_accepted_declaration { true }
    direct_otp_sent_at { Time.zone.now }
    direct_otp { "12345" }
    mobile_number_verified { true }
    account_security_completed { true }

    factory :submit_user, class: "SubmitUser" do
      confirmed_at { 1.hour.ago }

      trait :with_responsible_person do
        after(:create) do |user|
          create_list(:responsible_person_user, 1, user: user)
        end
      end

      trait :confirmed_not_verified do
        confirmed_at { 1.hour.ago }
        confirmation_sent_at { Time.zone.now }
        confirmation_token { Devise.friendly_token }
        mobile_number_verified { false }
      end

      trait :unconfirmed do
        password { nil }
        mobile_number { nil }
        mobile_number_verified { false }
        confirmed_at { nil }
        confirmation_sent_at { Time.zone.now }
        direct_otp_sent_at { nil }
        direct_otp { nil }
        confirmation_token { Devise.friendly_token }
        to_create { |user| user.save(validate: false) }
        account_security_completed { false }
      end
    end

    factory :search_user, class: "SearchUser" do
      role {}

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
        password { nil }
        mobile_number { nil }
        invitation_token { Devise.friendly_token }
        invited_at { Time.zone.now }
        direct_otp_sent_at { nil }
        direct_otp { nil }
        to_create { |user| user.save(validate: false) }
        account_security_completed { false }
      end
    end
  end
end
