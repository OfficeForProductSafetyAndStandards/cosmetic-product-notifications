module Types
  module ComponentNanoMaterialQueries
    extend ActiveSupport::Concern

    included do
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

      field :component_nano_materials, [ComponentNanoMaterialType], null: false, camelize: false, description: <<~DESC
        Retrieve a list of all ComponentNanoMaterials.

        Example Query:
        ```
        query {
          component_nano_materials {
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
            created_at
            updated_at
          }
        }
        ```
      DESC
    end

    def component_nano_material(id:)
      ComponentNanoMaterial.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find component_nano_material with 'id'=#{id}"
    end

    def component_nano_materials
      ComponentNanoMaterial.all
    end
  end
end
