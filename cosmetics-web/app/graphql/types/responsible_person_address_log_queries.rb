module Types
  module ResponsiblePersonAddressLogQueries
    extend ActiveSupport::Concern

    included do
      # Query for retrieving a specific responsible person address log by its ID
      field :responsible_person_address_log, ResponsiblePersonAddressLogType, null: false, camelize: false, description: <<~DESC do
        Retrieve a specific responsible person address log by its ID.

        Example Query:
        ```
        query {
          responsible_person_address_log(id: 1) {
            id
            line_1
            line_2
            city
            county
            postal_code
            start_date
            end_date
            created_at
            updated_at
            responsible_person {
              id
              name
            }
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the responsible person address log to retrieve"
      end

      # Add cursor-based pagination for responsible_person_address_logs
      field :responsible_person_address_logs, ResponsiblePersonAddressLogType.connection_type, null: false, camelize: false, description: <<~DESC
        Retrieve a paginated list of responsible person address logs.

        Example Query:
        ```
        query {
          responsible_person_address_logs(first: 10, after: "<cursor>") {
            edges {
              node {
                id
                line_1
                line_2
                city
                county
                postal_code
                start_date
                end_date
                created_at
                updated_at
                responsible_person {
                  id
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

    # Method to return a specific responsible person address log by ID
    def responsible_person_address_log(id:)
      ResponsiblePersonAddressLog.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find responsible_person_address_log with 'id'=#{id}"
    end

    # Method to return all responsible person address logs with pagination support and a max limit of 100 records
    def responsible_person_address_logs(first: nil, last: nil, after: nil, before: nil)
      max_limit = 100
      _after = after
      _before = before

      first = first ? [first, max_limit].min : nil
      last = last ? [last, max_limit].min : nil

      ResponsiblePersonAddressLog.limit(first || last)
    end
  end
end
