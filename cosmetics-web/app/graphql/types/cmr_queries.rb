module Types
  module CmrQueries
    extend ActiveSupport::Concern

    included do
      field :cmrs, [CmrType], null: true, camelize: false, description: <<~DESC
        Retrieve a list of CMRs.

        Example Query:
        ```
        query {
          cmrs {
            id
            name
            cas_number
            ec_number
            component_id
            created_at
            updated_at
          }
        }
        ```
      DESC

      field :cmr, CmrType, null: true, description: <<~DESC do
        Retrieve a specific CMR by its ID.

        Example Query:
        ```
        query {
          cmr(id: 1) {
            id
            name
            cas_number
            ec_number
            component_id
            created_at
            updated_at
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the CMR to retrieve"
      end
    end

    def cmrs
      Cmr.all
    end

    def cmr(id:)
      Cmr.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find CMR with 'id'=#{id}"
    end
  end
end
