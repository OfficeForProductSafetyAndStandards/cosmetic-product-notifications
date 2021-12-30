FactoryBot.define do
  factory :deleted_notification do
    association :notification, :deleted
  end
end
