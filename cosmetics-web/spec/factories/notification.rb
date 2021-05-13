FactoryBot.define do
  factory :notification do
    responsible_person
    sequence(:product_name) { |n| "Product #{n}" }

    factory :draft_notification do
      state { :draft_complete }

      after(:create) do |notification|
        create(:component, notification: notification)
        notification.reload
      end
    end

    factory :imported_notification do
      state { :notification_file_imported }
    end

    factory :registered_notification, traits: [:registered]

    trait :imported do
      import_country { "country:FR" }
    end

    trait :registered do
      state { :notification_complete }
      notification_complete_at { Time.zone.now }
    end

    trait :ph_values do
      ph_min_value { 4 }
      ph_max_value { 8 }
    end

    trait :manual do
      cpnp_reference { nil }
    end

    trait :via_zip_file do
      state { :notification_file_imported }
      cpnp_reference { "123456789" }
    end

    trait :with_component do
      after(:create) do |notification|
        create(:component, notification: notification, sub_sub_category: "nonoxidative_hair_colour_products")
        notification.reload
      end
    end

    trait :with_components do
      after(:create) do |notification|
        create(:component, notification: notification, sub_sub_category: "nonoxidative_hair_colour_products")
        create(:component, notification: notification, sub_sub_category: "nonoxidative_hair_colour_products")
        notification.reload
      end
    end
  end
end
