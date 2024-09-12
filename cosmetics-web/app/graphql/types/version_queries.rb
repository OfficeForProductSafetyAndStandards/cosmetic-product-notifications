module Types
  module VersionQueries
    extend ActiveSupport::Concern

    included do
      # Query for retrieving a specific version by its ID
      field :version, VersionType, null: false, camelize: false, description: <<~DESC do
        Retrieve a specific version by its ID.

        Example Query:
        ```
        query {
          version(id: 1) {
            id
            item_type
            item_id
            event
            whodunnit
            object
            object_changes
            created_at
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the version to retrieve"
      end

      # Add cursor-based pagination for versions
      field :versions, VersionType.connection_type, null: false, camelize: false, description: <<~DESC
        Retrieve a paginated list of all versions.

        Example Query:
        ```
        query {
          versions(first: 10, after: "<cursor>") {
            edges {
              node {
                id
                item_type
                item_id
                event
                whodunnit
                object
                object_changes
                created_at
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

      field :total_versions_count, Integer, null: false, camelize: false, description: <<~DESC
        Retrieve the total number of versions available.

        Example Query:
        ```
        query {
          total_versions_count
        }
        ```
      DESC
    end

    # Method to return a specific version by ID
    def version(id:)
      PaperTrail::Version.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find version with 'id'=#{id}"
    end

    # Method to return all versions with pagination support and a max limit of 100 records
    def versions(first: nil, last: nil, after: nil, before: nil)
      max_limit = 100
      _after = after
      _before = before

      first = first ? [first, max_limit].min : nil
      last = last ? [last, max_limit].min : nil

      PaperTrail::Version.limit(first || last)
    end

    def total_versions_count
      PaperTrail::Version.count
    end
  end
end
