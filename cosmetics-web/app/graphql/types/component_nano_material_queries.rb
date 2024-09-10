module Types
  module ComponentNanoMaterialQueries
    extend ActiveSupport::Concern

    included do
      # Query for retrieving a specific ComponentNanoMaterial by its ID
      field :component_nano_material, ComponentNanoMaterialType, null: false, camelize: false, description: <<~DESC do
        Retrieve a specific ComponentNanoMaterial by its ID.

        Example Query:
        ```
        query {
          component_nano_material(id: 1) {
            id
            component {
              id
              name
              state
              shades
            }
            nano_material {
              id
              inci_name
              inn_name
              iupac_name
              xan_name
              cas_number
              ec_number
              einecs_number
            }
            created_at
            updated_at
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the ComponentNanoMaterial to retrieve"
      end

      # Add cursor-based pagination for component_nano_materials
      field :component_nano_materials, ComponentNanoMaterialType.connection_type, null: false, camelize: false, description: <<~DESC
        Retrieve a paginated list of ComponentNanoMaterials.

        Example Query:
        ```
        query {
          component_nano_materials(first: 10, after: "<cursor>") {
            edges {
              node {
                id
                component {
                  id
                  name
                  state
                  shades
                }
                nano_material {
                  id
                  inci_name
                  inn_name
                  iupac_name
                  xan_name
                  cas_number
                  ec_number
                  einecs_number
                }
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
    end

    # Method to return a specific ComponentNanoMaterial by ID
    def component_nano_material(id:)
      ComponentNanoMaterial.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find component_nano_material with 'id'=#{id}"
    end

    # Method to return all ComponentNanoMaterials with pagination support and a max limit of 100 records
    def component_nano_materials(first: nil, last: nil, after: nil, before: nil)
      max_limit = 100
      _after = after
      _before = before

      first = first ? [first, max_limit].min : nil
      last = last ? [last, max_limit].min : nil

      ComponentNanoMaterial.limit(first || last)
    end
  end
end
