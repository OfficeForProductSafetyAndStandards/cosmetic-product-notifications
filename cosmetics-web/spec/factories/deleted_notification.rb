FactoryBot.define do
  factory :deleted_notification do
    association :notification

    product_name { "Test Product" }
    state { "Test State" }

    created_at { Time.current }
    updated_at { Time.current }
  end
end
