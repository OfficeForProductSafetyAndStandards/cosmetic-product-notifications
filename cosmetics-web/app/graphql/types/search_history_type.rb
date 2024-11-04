module Types
  class SearchHistoryType < Types::BaseObject
    field :id, ID, null: false
    field :query, String, null: true, description: "The search query term"
    field :results, Integer, null: false
    field :sort_by, String, null: true, camelize: false
    field :created_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the search was performed"
    field :updated_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the search history was last updated"
  end
end
