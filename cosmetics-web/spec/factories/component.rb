FactoryBot.define do
  factory :component do
    notification_type { "predefined" }
    notification

    factory :predefined_component
    factory :ranges_component do
      notification_type { "range" }
    end
    factory :exact_component do
      notification_type { "exact" }
    end

    trait :with_poisonous_ingredients do
      contains_poisonous_ingredients { true }
    end

    trait :with_trigger_questions do
      trigger_questions { build_list :trigger_question, 2 }
    end

    trait :with_name do
      name { "a component" }
    end

    trait :using_exact do
      notification_type { "exact" }
    end

    trait :using_range do
      notification_type { "range" }
    end

    trait :using_frame_formulation do
      notification_type { "predefined" }
      frame_formulation { "skin_care_cream_lotion_gel_with_high_level_of_perfume" }
    end

    trait :with_range_formulas do
      notification_type { "range" }
      after(:create) do |component|
        create(:range_formula, component: component)
      end
    end

    trait :with_exact_formulas do
      notification_type { "exact" }
      after(:create) do |component|
        create(:exact_formula, component: component)
      end
    end

    trait :with_formulation_file do
      formulation_file { Rack::Test::UploadedFile.new("spec/fixtures/files/testPdf.pdf", "application/pdf") }
    end
  end
end
