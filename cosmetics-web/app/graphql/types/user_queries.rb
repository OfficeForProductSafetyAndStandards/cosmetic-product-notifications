module Types
  module UserQueries
    extend ActiveSupport::Concern

    included do
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
            responsible_persons {
              id
              name
            }
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the user to retrieve"
      end

      field :users, [UserType], null: false, camelize: false, description: <<~DESC
        Retrieve a list of all users.

        Example Query:
        ```
        query {
          users {
            id
            name
            email
            created_at
            updated_at
          }
        }
        ```
      DESC
    end

    def user(id:)
      User.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find user with 'id'=#{id}"
    end

    def users
      User.all
    end
  end
end
