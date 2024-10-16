module Types
  class ResponsiblePersonType < Types::BaseObject
    field :id, ID, null: false
    field :account_type, String, null: true, camelize: false
    field :name, String, null: true
    field :address_line_1, String, null: true, camelize: false
    field :address_line_2, String, null: true, camelize: false
    field :city, String, null: true
    field :county, String, null: true
    field :postal_code, String, null: true, camelize: false
    field :created_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the responsible person was created"
    field :updated_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the responsible person was last updated"
    field :users, [UserType], null: false, description: "The users associated with this responsible person"
  end
end
