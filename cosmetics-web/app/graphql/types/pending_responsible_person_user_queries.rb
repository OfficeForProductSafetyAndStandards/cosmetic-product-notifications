module Types
  module PendingResponsiblePersonUserQueries
    extend ActiveSupport::Concern

    included do
      # Query for retrieving a specific pending responsible person user by its ID
      field :pending_responsible_person_user, PendingResponsiblePersonUserType, null: false, camelize: false, description: <<~DESC do
        Retrieve a specific pending responsible person user by its ID.

        Example Query:
        ```
        query {
          pending_responsible_person_user(id: 1) {
            id
            email_address
            created_at
            updated_at
            responsible_person {
              id
              name
            }
            invitation_token
            invitation_token_expires_at
            inviting_user {
              id
              email
              name
            }
            name
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the pending responsible person user to retrieve"
      end

      # Add cursor-based pagination for pending_responsible_person_users
      field :pending_responsible_person_users, PendingResponsiblePersonUserType.connection_type, null: false, camelize: false, description: <<~DESC
        Retrieve a paginated list of pending responsible person users.

        Example Query:
        ```
        query {
          pending_responsible_person_users(first: 10, after: "<cursor>") {
            edges {
              node {
                id
                email_address
                created_at
                updated_at
                responsible_person {
                  id
                  name
                }
                invitation_token
                invitation_token_expires_at
                inviting_user {
                  id
                  email
                  name
                }
                name
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

      field :total_pending_responsible_person_users_count, Integer, null: false, camelize: false, description: <<~DESC
        Retrieve the total number of pending_responsible_person_users available.

        Example Query:
        ```
        query {
          total_pending_responsible_person_users_count
        }
        ```
      DESC
    end

    # Method to return a specific pending responsible person user by ID
    def pending_responsible_person_user(id:)
      PendingResponsiblePersonUser.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find pending_responsible_person_user with 'id'=#{id}"
    end

    # Method to return all pending responsible person users with pagination support and a max limit of 100 records
    def pending_responsible_person_users(first: nil, last: nil, after: nil, before: nil)
      max_limit = 100
      _after = after
      _before = before

      first = first ? [first, max_limit].min : nil
      last = last ? [last, max_limit].min : nil

      PendingResponsiblePersonUser.limit(first || last)
    end

    def total_pending_responsible_person_users_count
      PendingResponsiblePersonUser.count
    end
  end
end
