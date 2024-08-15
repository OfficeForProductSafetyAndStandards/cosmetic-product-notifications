module Types
  module ContactPersonQueries
    extend ActiveSupport::Concern

    included do
      field :contact_person, ContactPersonType, null: false, camelize: false, description: <<~DESC do
        Retrieve a specific contact person by its ID.

        Example Query:
        ```
        query {
          contact_person(id: 1) {
            id
            name
            email_address
            phone_number
            responsible_person_id
            created_at
            updated_at
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the contact person to retrieve"
      end

      field :contact_persons, [ContactPersonType], null: false, camelize: false, description: <<~DESC
        Retrieve a list of all contact persons.

        Example Query:
        ```
        query {
          contact_persons {
            id
            name
            email_address
            phone_number
            responsible_person_id
            created_at
            updated_at
          }
        }
        ```
      DESC
    end

    def contact_person(id:)
      ContactPerson.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find contact_person with 'id'=#{id}"
    end

    def contact_persons
      ContactPerson.all
    end
  end
end
