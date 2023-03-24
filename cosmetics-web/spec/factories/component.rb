FactoryBot.define do
  factory :component do
    notification_type { "predefined" }
    notification

    factory :predefined_component do
      notification_type { "predefined" }

      trait :completed do
        state { "component_complete" }
        physical_form { "foam" }
        sub_sub_category { "shampoo" }
        frame_formulation { "skin_care_cream_lotion_gel" }
        contains_poisonous_ingredients { true }
        ph { "between_3_and_10" }
        routing_questions_answers do
          {
            "contains_cmrs" => "no",
            "number_of_shades" => "single-or-no-shades",
            "select_formulation_type" => "predefined",
            "contains_special_applicator" => "no",
            "contains_poisonous_ingredients" => "true",
          }
        end
      end
    end

    factory :ranges_component do
      notification_type { "range" }

      trait :completed do
        state { "component_complete" }
        physical_form { "foam" }
        sub_sub_category { "shampoo" }
        ph { "between_3_and_10" }
        routing_questions_answers do
          {
            "contains_cmrs" => "no",
            "number_of_shades" => "single-or-no-shades",
            "select_formulation_type" => "range",
            "contains_special_applicator" => "no",
            "contains_poisonous_ingredients" => "true",
          }
        end
      end

      trait :with_multiple_shades do
        routing_questions_answers do
          {
            "contains_cmrs" => "no",
            "number_of_shades" => "multiple-shades-same-notification",
            "select_formulation_type" => "range",
            "contains_special_applicator" => "no",
            "contains_poisonous_ingredients" => "true",
          }
        end
        shades { %w[Black White] }
      end
    end

    factory :exact_component do
      notification_type { "exact" }

      trait :completed do
        state { "component_complete" }
        physical_form { "foam" }
        sub_sub_category { "shampoo" }
        ph { "between_3_and_10" }
        routing_questions_answers do
          {
            "contains_cmrs" => "no",
            "number_of_shades" => "single-or-no-shades",
            "select_formulation_type" => "exact",
            "contains_special_applicator" => "no",
            "contains_poisonous_ingredients" => "true",
          }
        end
      end

      trait :with_multiple_shades do
        routing_questions_answers do
          {
            "contains_cmrs" => "no",
            "number_of_shades" => "multiple-shades-same-notification",
            "select_formulation_type" => "exact",
            "contains_special_applicator" => "no",
            "contains_poisonous_ingredients" => "true",
          }
        end
        shades { %w[Black White] }
      end
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

    trait :with_category do
      sub_sub_category { "shampoo" }
    end

    trait :with_other_category do
      sub_sub_category { "other_skin_care_products_child" }
    end

    trait :with_range_ingredients do
      notification_type { "range" }
      after(:create) do |component|
        create(:range_ingredient, component:)
      end
    end

    trait :with_exact_ingredient do
      notification_type { "exact" }
      after(:create) do |component|
        create(:exact_ingredient, component:)
      end
    end

    trait :with_ingredients_file do
      notification_type { "exact" }
      ingredients_file { Rack::Test::UploadedFile.new("spec/fixtures/files/Exact_ingredients.csv", "application/pdf") }
    end

    trait :with_exact_ingredients do
      notification_type { "exact" }
      after(:create) do |component|
        create_list(:exact_ingredient, 2, component:)
      end
    end

    trait :with_formulation_file do
      formulation_file { Rack::Test::UploadedFile.new("spec/fixtures/files/testPdf.pdf", "application/pdf") }
    end

    trait :ph_not_required do
      physical_form { "loose_powder" }
    end

    transient do
      with_nano_materials { [] }
    end

    transient do
      with_ingredients { [] }
    end

    after(:create) do |component, evaluator|
      evaluator.with_nano_materials.each do |nano_material|
        component.nano_materials << nano_material
      end

      evaluator.with_ingredients.each do |ingredient|
        component.ingredients << create(:exact_ingredient, component:, inci_name: ingredient)
      end
    end
  end
end
