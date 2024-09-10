module Types
  module CmrQueries
    extend ActiveSupport::Concern

    included do
      # Query for retrieving a specific CMR by its ID
      field :cmr, CmrType, null: true, description: <<~DESC do
        Retrieve a specific CMR by its ID.

        Example Query:
        ```
        query {
          cmr(id: 1) {
            id
            name
            cas_number
            ec_number
            component_id
            created_at
            updated_at
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the CMR to retrieve"
      end

      # Cursor-based pagination for CMRs with a maximum limit of 100 records per page
      field :cmrs, CmrType.connection_type, null: true, camelize: false, description: <<~DESC
        Retrieve a paginated list of CMRs with a maximum of 100 records per page.

        Example Query:
        ```
        query {
          cmrs(first: 10, after: "<cursor>") {
            edges {
              node {
                id
                name
                cas_number
                ec_number
                component_id
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
    end

    # Method to return a specific CMR by ID
    def cmr(id:)
      Cmr.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find cmr with 'id'=#{id}"
    end

    # Method to return all CMRs with pagination support and a max limit of 100 records
    def cmrs(first: nil, last: nil, after: nil, before: nil)
      max_limit = 100
      _after = after
      _before = before

      first = first ? [first, max_limit].min : nil
      last = last ? [last, max_limit].min : nil

      Cmr.limit(first || last)
    end
  end
end
