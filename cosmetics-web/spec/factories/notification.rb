FactoryBot.define do
  factory :notification do
    factory :draft_notification do
      state { :draft_complete }
    end
  end
end
