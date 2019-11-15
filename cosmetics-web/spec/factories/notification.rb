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

    trait :imported do
      import_country { "country:FR" }
    end

    trait :registered do
      state { :notification_complete }
    end

    trait :ph_values do
      ph_min_value { 4 }
      ph_max_value { 8 }
    end

    trait :pre_brexit do
      was_notified_before_eu_exit { true }
    end

    trait :post_brexit do
      was_notified_before_eu_exit { false }
    end

    trait :via_zip_file do
      state { :notification_file_imported }
      cpnp_reference { "123456789" }
    end
  end
end
