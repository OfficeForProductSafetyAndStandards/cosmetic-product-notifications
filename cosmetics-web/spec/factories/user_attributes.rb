FactoryBot.define do
  factory :user_attributes do
    transient do
      declaration_accepted { true }
    end

    declaration_accepted_at { Time.zone.now if declaration_accepted }
  end
end
