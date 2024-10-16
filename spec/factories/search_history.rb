FactoryBot.define do
  factory :search_history do
    query { "Example search query" }
    results { rand(1..100) }
    sort_by { "relevance" }
    created_at { Time.current }
    updated_at { Time.current }
  end
end
