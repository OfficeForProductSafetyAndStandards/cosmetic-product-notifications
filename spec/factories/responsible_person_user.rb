FactoryBot.define do
  factory :responsible_person_user do
    user factory: :submit_user
    association :responsible_person, :with_a_contact_person
  end
end
