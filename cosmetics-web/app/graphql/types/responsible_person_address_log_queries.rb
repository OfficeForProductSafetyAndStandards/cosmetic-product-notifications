module Types
  module ResponsiblePersonAddressLogQueries
    extend ActiveSupport::Concern

    included do
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

      field :responsible_person_address_logs, [ResponsiblePersonAddressLogType], null: false, camelize: false, description: <<~DESC
        Retrieve a list of all responsible person address logs.

        Example Query:
        ```
        query {
          responsible_person_address_logs {
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
    end

    def responsible_person_address_log(id:)
      ResponsiblePersonAddressLog.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find ResponsiblePersonAddressLog with 'id'=#{id}"
    end

    def responsible_person_address_logs
      ResponsiblePersonAddressLog.all
    end
  end
end
