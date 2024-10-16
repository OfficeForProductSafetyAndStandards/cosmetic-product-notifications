module Types
  class ContactPersonType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: true
    field :email_address, String, null: true, camelize: false
    field :phone_number, String, null: true, camelize: false
    field :created_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the contact person was created"
    field :updated_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the contact person was last updated"
    field :responsible_person_id, ID, null: true, camelize: false
    field :responsible_person, ResponsiblePersonType, null: true, camelize: false, description: "The associated responsible person"
  end
end
