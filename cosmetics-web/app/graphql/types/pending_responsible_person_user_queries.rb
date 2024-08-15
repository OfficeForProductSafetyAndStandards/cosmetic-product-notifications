# app/graphql/types/pending_responsible_person_user_queries.rb
module Types
  module PendingResponsiblePersonUserQueries
    extend ActiveSupport::Concern

    included do
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

      field :pending_responsible_person_users, [PendingResponsiblePersonUserType], null: false, camelize: false, description: <<~DESC
        Retrieve a list of all pending responsible person users.

        Example Query:
        ```
        query {
          pending_responsible_person_users {
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
    end

    def pending_responsible_person_user(id:)
      PendingResponsiblePersonUser.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find PendingResponsiblePersonUser with 'id'=#{id}"
    end

    def pending_responsible_person_users
      PendingResponsiblePersonUser.all
    end
  end
end
