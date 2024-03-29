FactoryBot.define do
  factory :notification do
    responsible_person
    sequence(:product_name) { |n| "Product #{n}" }
    cpnp_reference { nil }
    under_three_years { true }

    factory :draft_notification do
      state { NotificationStateConcern::COMPONENTS_COMPLETE }

      after(:create) do |notification|
        create(:component, notification:)
        notification.reload
      end
    end

    factory :registered_notification, traits: [:registered]
    factory :archived_notification, traits: %i[registered archived]

    trait :registered do
      state { NotificationStateConcern::NOTIFICATION_COMPLETE }
      notification_complete_at { Time.zone.now }
    end

    trait :draft_complete do
      state { NotificationStateConcern::COMPONENTS_COMPLETE }
    end

    trait :archived do
      archive_reason { "significant_change_to_the_formulation" }

      after(:create) do |notification, _evaluator|
        Notification.import_to_opensearch(force: true)
        notification.archive
        notification.reload
      end
    end

    trait :ph_values do
      ph_min_value { 7 }
      ph_max_value { 8 }
    end

    trait :with_component do
      transient do
        category { "nonoxidative_hair_colour_products" }
      end

      after(:create) do |notification, evaluator|
        create(:component, notification:, sub_sub_category: evaluator.category)
        notification.reload
      end
    end

    trait :with_components do
      after(:create) do |notification|
        create(:component, notification:, sub_sub_category: "nonoxidative_hair_colour_products")
        create(:component, notification:, sub_sub_category: "nonoxidative_hair_colour_products")
        notification.reload
      end
    end

    trait :with_nano_material do
      after(:create) do |notification|
        create(:nano_material, notification:)
        notification.reload
      end
    end

    trait :with_nano_materials do
      after(:create) do |notification|
        create_list(:nano_material, 2, notification:)
        notification.reload
      end
    end

    trait :with_label_image do
      image_uploads { [build(:image_upload, :uploaded_and_virus_scanned)] }
    end

    trait :skip_validations do
      to_create { |instance| instance.save(validate: false) }
    end

    trait :deleted do
      skip_validations
      deleted_at { Time.zone.now }
      state { NotificationStateConcern::DELETED }
      Notification::DELETABLE_ATTRIBUTES.each do |attribute|
        send(attribute) { nil }
      end

      after(:create) do |notification|
        create(:deleted_notification, notification:)
        notification.reload
      end
    end
  end
end
