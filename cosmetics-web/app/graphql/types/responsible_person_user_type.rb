module Types
  class ResponsiblePersonUserType < Types::BaseObject
    field :id, ID, null: false
    field :created_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the user was associated with the responsible person"
    field :updated_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the association was last updated"
    field :responsible_person_id, GraphQL::Types::ID, null: true, camelize: false
    field :responsible_person, ResponsiblePersonType, null: true, camelize: false, description: "The associated responsible person"
    field :user_id, String, null: false, camelize: false
    field :user, UserType, null: false, description: "The associated user, including its details"
  end
end
