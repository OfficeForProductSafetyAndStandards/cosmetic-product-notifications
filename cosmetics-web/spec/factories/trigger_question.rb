FactoryBot.define do
  factory :trigger_question do
    question { "What is your favorite color?" }
    association :component
  end
end
