module Types
  module VersionQueries
    extend ActiveSupport::Concern

    included do
      field :version, VersionType, null: false, camelize: false, description: <<~DESC do
        Retrieve a specific version by its ID.

        Example Query:
        ```
        query {
          version(id: 1) {
            id
            item_type
            item_id
            event
            whodunnit
            object
            object_changes
            created_at
          }
        }
        ```
      DESC
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the version to retrieve"
      end

      field :versions, [VersionType], null: false, camelize: false, description: <<~DESC
        Retrieve a list of all versions.

        Example Query:
        ```
        query {
          versions {
            id
            item_type
            item_id
            event
            whodunnit
            object
            object_changes
            created_at
          }
        }
        ```
      DESC
    end

    def version(id:)
      PaperTrail::Version.find(id)
    rescue ActiveRecord::RecordNotFound
      raise Errors::SimpleError, "Couldn't find Version with 'id'=#{id}"
    end

    def versions
      PaperTrail::Version.all
    end
  end
end
