FactoryBot.define do
  factory :user do
    name { "John Doe" }
    sequence(:email) { |n| "john.doe#{n}@example.org" }
    mobile_number { "07500 000 000" }
    password { "testpassword123" }
    confirmed_at { 1.hour.ago }
    has_accepted_declaration { true }
    direct_otp_sent_at { Time.current }
    direct_otp { "12345" }
    mobile_number_verified { true }
    account_security_completed { true }

    factory :submit_user, class: "SubmitUser" do
      trait :with_responsible_person do
        after(:create) do |user|
          create_list(:responsible_person_user, 1, user: user)
        end
      end

      trait :unconfirmed do
        password { nil }
        mobile_number { nil }
        confirmed_at { nil }
        confirmation_sent_at { Time.current }
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
    end
  end
end
