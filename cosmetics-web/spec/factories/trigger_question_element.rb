FactoryBot.define do
  factory :trigger_question_element do
    answer_order { 1 }
    answer { "Sample Answer" }
    element_order { 1 }
    element { "ethanol" }
    created_at { Time.current }
    updated_at { Time.current }

    association :trigger_question
  end
end
