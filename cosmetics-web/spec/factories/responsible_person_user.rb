FactoryBot.define do
  factory :responsible_person_user do
    association :user, factory: :submit_user
    association :responsible_person
  end
end
