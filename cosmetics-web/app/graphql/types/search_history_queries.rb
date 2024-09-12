module Types
  module SearchHistoryQueries
    extend ActiveSupport::Concern

    included do
      # Query for retrieving a specific search history by its ID
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

      # Add cursor-based pagination for search_histories
      field :search_histories, SearchHistoryType.connection_type, null: false, camelize: false, description: <<~DESC
        Retrieve a paginated list of all search histories.

        Example Query:
        ```
        query {
          search_histories(first: 10, after: "<cursor>") {
            edges {
              node {
                id
                query
                results
                sort_by
                created_at
                updated_at
              }
              cursor
            }
            pageInfo {
              hasNextPage
              hasPreviousPage
              startCursor
              endCursor
            }
          }
        }
        ```
      DESC

      field :total_search_histories_count, Integer, null: false, camelize: false, description: <<~DESC
        Retrieve the total number of search_histories available.

        Example Query:
        ```
        query {
          total_search_histories_count
        }
        ```
      DESC
    end

    # Method to return a specific search history by ID
    def search_history(id:)
      SearchHistory.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find search_history with 'id'=#{id}"
    end

    # Method to return all search histories with pagination support and a max limit of 100 records
    def search_histories(first: nil, last: nil, after: nil, before: nil)
      max_limit = 100
      _after = after
      _before = before

      first = first ? [first, max_limit].min : nil
      last = last ? [last, max_limit].min : nil

      SearchHistory.limit(first || last)
    end

    def total_search_histories_count
      SearchHistory.count
    end
  end
end
