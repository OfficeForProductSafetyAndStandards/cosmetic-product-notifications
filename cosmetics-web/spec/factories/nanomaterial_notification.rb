FactoryBot.define do
  factory :nanomaterial_notification do
    name { "Zinc oxide" }
    user_id { "123-456-abc" }

    trait :not_submitted do
      submitted_at { nil }
    end

    trait :submitted do
      submitted_at { 1.hour.ago }
    end
  end
end
