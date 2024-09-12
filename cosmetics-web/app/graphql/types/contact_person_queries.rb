module Types
  module ContactPersonQueries
    extend ActiveSupport::Concern

    included do
      # Query for retrieving a specific contact person by its ID
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

      # Add cursor-based pagination for contact_persons
      field :contact_persons, ContactPersonType.connection_type, null: false, camelize: false, description: <<~DESC
        Retrieve a paginated list of contact persons.

        Example Query:
        ```
        query {
          contact_persons(first: 10, after: "<cursor>") {
            edges {
              node {
                id
                name
                email_address
                phone_number
                responsible_person_id
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

      field :total_contact_persons_count, Integer, null: false, camelize: false, description: <<~DESC
        Retrieve the total number of contact_person available.

        Example Query:
        ```
        query {
          total_contact_persons_count
        }
        ```
      DESC
    end

    # Method to return a specific contact person by ID
    def contact_person(id:)
      ContactPerson.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find contact_person with 'id'=#{id}"
    end

    # Method to return all contact persons with pagination support and a max limit of 100 records
    def contact_persons(first: nil, last: nil, after: nil, before: nil)
      max_limit = 100
      _after = after
      _before = before

      first = first ? [first, max_limit].min : nil
      last = last ? [last, max_limit].min : nil

      ContactPerson.limit(first || last)
    end

    def total_contact_persons_count
      ContactPerson.count
    end
  end
end
