FactoryBot.define do
  factory :trigger_question_element do
    trait :without_validations do
      to_create { |instance| instance.save(validate: false) }
    end
  end
end
