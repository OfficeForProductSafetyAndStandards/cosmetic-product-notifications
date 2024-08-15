module Types
  module NanoMaterialQueries
    extend ActiveSupport::Concern

    included do
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

      field :nano_materials, [NanoMaterialType], null: false, camelize: false, description: <<~DESC
        Retrieve a list of all nano materials.

        Example Query:
        ```
        query {
          nano_materials {
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
    end

    def nano_material(id:)
      NanoMaterial.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find NanoMaterial with 'id'=#{id}"
    end

    def nano_materials
      NanoMaterial.all
    end
  end
end
