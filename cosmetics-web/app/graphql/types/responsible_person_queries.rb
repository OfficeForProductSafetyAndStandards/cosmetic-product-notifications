module Types
  module ResponsiblePersonQueries
    extend ActiveSupport::Concern

    included do
      # Query for retrieving a specific responsible person by its ID
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

      # Add cursor-based pagination for responsible_persons
      field :responsible_persons, ResponsiblePersonType.connection_type, null: false, camelize: false, description: <<~DESC
        Retrieve a paginated list of responsible persons.

        Example Query:
        ```
        query {
          responsible_persons(first: 10, after: "<cursor>") {
            edges {
              node {
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

    # Method to return a specific responsible person by ID
    def responsible_person(id:)
      ResponsiblePerson.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find responsible_person with 'id'=#{id}"
    end

    # Method to return all responsible persons with pagination support and a max limit of 100 records
    def responsible_persons(first: nil, last: nil, after: nil, before: nil)
      max_limit = 100
      _after = after
      _before = before

      first = first ? [first, max_limit].min : nil
      last = last ? [last, max_limit].min : nil

      ResponsiblePerson.limit(first || last)
    end
  end
end
