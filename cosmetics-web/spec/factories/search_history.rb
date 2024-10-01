FactoryBot.define do
  factory :search_history do
    query { "Example search query" }
    results { "Some results" }
    sort_by { "relevance" }
    created_at { Time.current }
    updated_at { Time.current }
  end
end
