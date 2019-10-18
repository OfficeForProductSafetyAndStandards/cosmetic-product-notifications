FactoryBot.define do
  factory :notification do
    sequence(:product_name) { |n| "Product #{n}" }

    factory :draft_notification do
      state { :draft_complete }
    end

    factory :imported_notification do
      state { :notification_file_imported }
    end

    factory :registered_notification do
      state { :notification_complete }
    end

    factory :pre_eu_exit_notification do
      was_notified_before_eu_exit { true }
    end

    trait :imported do
      import_country { "country:FR" }
    end

    trait :registered do
      state { :notification_complete }
    end
  end
end
