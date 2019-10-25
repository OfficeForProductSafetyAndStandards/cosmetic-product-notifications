FactoryBot.define do
  factory :component do
    notification_type { "predefined" }
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
  end
end
