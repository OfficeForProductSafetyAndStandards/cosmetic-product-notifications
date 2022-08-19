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
    end

    trait :range do
      range_concentration { "greater_than_75_less_than_100_percent" }
      association :component, notification_type: "range"
    end
  end
end
