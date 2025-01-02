module Types
  class VersionType < BaseObject
    graphql_name "Version"
    description "A record of changes tracked by PaperTrail."

    field :id, ID, null: false, camelize: false
    field :item_type, String, null: false, camelize: false, description: "The ActiveRecord model name (e.g. 'User')"
    field :item_id, ID, null: false, camelize: false, description: "ID of the record that was versioned"
    field :event, String, null: false, camelize: false, description: "PaperTrail event (create/update/destroy)"
    field :whodunnit, String, null: true, camelize: false, description: "Who or what made the change"
    field :object_state, GraphQL::Types::JSON, null: true, camelize: false, description: "State of the record prior to this version (if retained)", method: :object
    field :object_changes, GraphQL::Types::JSON, null: true, camelize: false, description: "Diff of changes in this version (if retained)"
    field :created_at, GraphQL::Types::ISO8601DateTime, null: true, camelize: false, description: "When the version was created"
  end
end
