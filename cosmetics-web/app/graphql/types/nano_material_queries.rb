module Types
  module NanoMaterialQueries
    extend ActiveSupport::Concern

    included do
      # Query for retrieving a specific nano material by its ID
      field :nano_material, NanoMaterialType, null: false, camelize: false, description: <<~DESC do
        Retrieve a specific nano material by its ID.

        Example Query:
        ```
        query {
          nano_material(id: 1) {
            id
            created_at
            updated_at
            notification_id
            inci_name
            inn_name
            iupac_name
            xan_name
            cas_number
            ec_number
            einecs_number
            elincs_number
            purposes
            confirm_toxicology_notified
            confirm_usage
            confirm_restrictions
            nanomaterial_notification_id
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the nano material to retrieve"
      end

      # Add cursor-based pagination for nano_materials
      field :nano_materials, NanoMaterialType.connection_type, null: false, camelize: false, description: <<~DESC
        Retrieve a paginated list of nano materials.

        Example Query:
        ```
        query {
          nano_materials(first: 10, after: "<cursor>") {
            edges {
              node {
                id
                created_at
                updated_at
                notification_id
                inci_name
                inn_name
                iupac_name
                xan_name
                cas_number
                ec_number
                einecs_number
                elincs_number
                purposes
                confirm_toxicology_notified
                confirm_usage
                confirm_restrictions
                nanomaterial_notification_id
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

      field :total_nano_materials_count, Integer, null: false, camelize: false, description: <<~DESC
        Retrieve the total number of nano_materials available.

        Example Query:
        ```
        query {
          total_nano_materials_count
        }
        ```
      DESC
    end

    # Method to return a specific nano material by ID
    def nano_material(id:)
      NanoMaterial.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find nano_material with 'id'=#{id}"
    end

    # Method to return all nano materials with pagination support and a max limit of 100 records
    def nano_materials(first: nil, last: nil, after: nil, before: nil)
      max_limit = 100
      _after = after
      _before = before

      first = first ? [first, max_limit].min : nil
      last = last ? [last, max_limit].min : nil

      NanoMaterial.limit(first || last)
    end

    def total_nano_materials_count
      NanoMaterial.count
    end
  end
end
