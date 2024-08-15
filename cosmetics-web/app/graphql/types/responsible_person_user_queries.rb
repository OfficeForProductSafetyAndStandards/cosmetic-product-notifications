module Types
  module ResponsiblePersonUserQueries
    extend ActiveSupport::Concern

    included do
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

      field :responsible_person_users, [ResponsiblePersonUserType], null: false, camelize: false, description: <<~DESC
        Retrieve a list of all responsible person user associations.

        Example Query:
        ```
        query {
          responsible_person_users {
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
    end

    def responsible_person_user(id:)
      ResponsiblePersonUser.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find ResponsiblePersonUser with 'id'=#{id}"
    end

    def responsible_person_users
      ResponsiblePersonUser.all
    end
  end
end
