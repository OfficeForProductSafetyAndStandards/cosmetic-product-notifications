module Types
  module ResponsiblePersonUserQueries
    extend ActiveSupport::Concern

    included do
      # Query for retrieving a specific responsible person user by its ID
      field :responsible_person_user, ResponsiblePersonUserType, null: false, camelize: false, description: <<~DESC do
        Retrieve a specific responsible person user association by its ID.

        Example Query:
        ```
        query {
          responsible_person_user(id: 1) {
            id
            created_at
            updated_at
            responsible_person {
              id
              name
            }
            user {
              id
              email
              name
            }
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the responsible person user to retrieve"
      end

      # Add cursor-based pagination for responsible_person_users
      field :responsible_person_users, ResponsiblePersonUserType.connection_type, null: false, camelize: false, description: <<~DESC
        Retrieve a paginated list of responsible person user associations.

        Example Query:
        ```
        query {
          responsible_person_users(first: 10, after: "<cursor>") {
            edges {
              node {
                id
                created_at
                updated_at
                responsible_person {
                  id
                  name
                }
                user {
                  id
                  email
                  name
                }
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

    # Method to return a specific responsible person user by ID
    def responsible_person_user(id:)
      ResponsiblePersonUser.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find responsible_person_user with 'id'=#{id}"
    end

    # Method to return all responsible person users with pagination support and a max limit of 100 records
    def responsible_person_users(first: nil, last: nil, after: nil, before: nil)
      max_limit = 100
      _after = after
      _before = before

      first = first ? [first, max_limit].min : nil
      last = last ? [last, max_limit].min : nil

      ResponsiblePersonUser.limit(first || last)
    end
  end
end
