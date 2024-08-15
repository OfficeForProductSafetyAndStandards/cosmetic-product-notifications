module Types
  module SearchHistoryQueries
    extend ActiveSupport::Concern

    included do
      field :search_history, SearchHistoryType, null: false, camelize: false, description: <<~DESC do
        Retrieve a specific search history by its ID.

        Example Query:
        ```
        query {
          search_history(id: 1) {
            id
            query
            results
            sort_by
            created_at
            updated_at
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the search history to retrieve"
      end

      field :search_histories, [SearchHistoryType], null: false, camelize: false, description: <<~DESC
        Retrieve a list of all search histories.

        Example Query:
        ```
        query {
          search_histories {
            id
            query
            results
            sort_by
            created_at
            updated_at
          }
        }
        ```
      DESC
    end

    def search_history(id:)
      SearchHistory.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find SearchHistory with 'id'=#{id}"
    end

    def search_histories
      SearchHistory.all
    end
  end
end
