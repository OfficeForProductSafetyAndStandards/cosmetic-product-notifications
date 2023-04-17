FactoryBot.define do
  factory :ingredient do
    sequence(:inci_name) { |n| "Ingredient #{n}" }
    poisonous { false }
    component

    factory :exact_ingredient do
      exact
    end

    factory :range_ingredient do
      range
    end

    factory :poisonous_ingredient do
      poisonous
    end

    trait :poisonous do
      exact
      poisonous { true }
    end

    trait :exact do
      exact_concentration { 10 }
      association :component, notification_type: "exact"
    end

    trait :range do
      minimum_concentration { 75.0 }
      maximum_concentration { 100.0 }
      association :component, notification_type: "range"
    end
  end
end
