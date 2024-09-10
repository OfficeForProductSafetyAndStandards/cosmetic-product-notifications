module Types
  module UserQueries
    extend ActiveSupport::Concern

    included do
      # Query for retrieving a specific user by their ID
      field :user, UserType, null: false, camelize: false, description: <<~DESC do
        Retrieve a specific user by their ID.

        Example Query:
        ```
        query {
          user(id: "some-uuid") {
            id
            name
            email
            mobile_number
            mobile_number_verified
            created_at
            updated_at
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the user to retrieve"
      end

      # Add cursor-based pagination for users with a maximum limit of 100 records per page
      field :users, UserType.connection_type, null: false, camelize: false, description: <<~DESC
        Retrieve a paginated list of all users with a maximum of 100 records per page.

        Example Query:

        query {
          users(first: 10, after: "<cursor>") {
            edges {
              node {
                id
                name
                email
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

      DESC
    end

    # Method to return a specific user by ID
    def user(id:)
      User.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find user with 'id'=#{id}"
    end

    # Method to return all users with pagination support and a max limit of 100 records
    def users(first: nil, last: nil, after: nil, before: nil)
      max_limit = 100
      _after = after
      _before = before

      first = first ? [first, max_limit].min : nil
      last = last ? [last, max_limit].min : nil

      User.limit(first || last)
    end
  end
end
