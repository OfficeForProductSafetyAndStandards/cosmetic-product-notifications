FactoryBot.define do
  factory :component do
    notification_type { "predefined" }
    factory :ranges_component do
      notification_type { "range" }
    end
    factory :exact_component do
      notification_type { "exact" }
    end
    factory :poison_centre_component do
      notification_type { "exact" }
      sub_sub_category { :hair_conditioner }
    end
  end
end
