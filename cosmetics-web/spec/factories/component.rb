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
  end
end
