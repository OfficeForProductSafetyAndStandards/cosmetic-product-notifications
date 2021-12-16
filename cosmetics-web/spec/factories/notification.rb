FactoryBot.define do
  factory :notification do
    responsible_person
    sequence(:product_name) { |n| "Product #{n}" }
    cpnp_reference { nil }

    factory :draft_notification do
      state { :draft_complete }

      after(:create) do |notification|
        create(:component, notification: notification)
        notification.reload
      end
    end

    factory :registered_notification, traits: [:registered]
    factory :deleted_notification, traits: [:deleted]

    trait :registered do
      state { :notification_complete }
      notification_complete_at { Time.zone.now }
    end

    trait :draft_complete do
      state { :draft_complete }
    end

    trait :deleted do
      state { :deleted }
    end

    trait :ph_values do
      ph_min_value { 4 }
      ph_max_value { 8 }
    end

    trait :with_component do
      transient do
        category { "nonoxidative_hair_colour_products" }
      end

      after(:create) do |notification, evaluator|
        create(:component, notification: notification, sub_sub_category: evaluator.category)
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

    trait :with_label_image do
      image_uploads { [build(:image_upload, :uploaded_and_virus_scanned)] }
    end
  end
end
