module Types
  class ResponsiblePersonAddressLogType < Types::BaseObject
    field :id, ID, null: false
    field :line_1, String, null: false, camelize: false
    field :line_2, String, null: true, camelize: false
    field :city, String, null: false
    field :county, String, null: true
    field :postal_code, String, null: false, camelize: false
    field :start_date, Types::CustomDateTimeType, null: false, camelize: false
    field :end_date, Types::CustomDateTimeType, null: false, camelize: false
    field :created_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the address log was created"
    field :updated_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the address log was last updated"
    field :responsible_person_id, GraphQL::Types::ID, null: true, camelize: false
    field :responsible_person, ResponsiblePersonType, null: true, camelize: false, description: "The associated responsible person"
  end
end
