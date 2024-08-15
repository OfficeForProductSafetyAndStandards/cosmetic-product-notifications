module Types
  module ResponsiblePersonQueries
    extend ActiveSupport::Concern

    included do
      field :responsible_person, ResponsiblePersonType, null: false, camelize: false, description: <<~DESC do
        Retrieve a specific responsible person by its ID.

        Example Query:
        ```
        query {
          responsible_person(id: 1) {
            id
            account_type
            name
            address_line_1
            address_line_2
            city
            county
            postal_code
            created_at
            updated_at
            users {
              id
              email
              name
            }
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the responsible person to retrieve"
      end

      field :responsible_persons, [ResponsiblePersonType], null: false, camelize: false, description: <<~DESC
        Retrieve a list of all responsible persons.

        Example Query:
        ```
        query {
          responsible_persons {
            id
            account_type
            name
            address_line_1
            address_line_2
            city
            county
            postal_code
            created_at
            updated_at
            users {
              id
              email
              name
            }
          }
        }
        ```
      DESC
    end

    def responsible_person(id:)
      ResponsiblePerson.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find ResponsiblePerson with 'id'=#{id}"
    end

    def responsible_persons
      ResponsiblePerson.all
    end
  end
end
