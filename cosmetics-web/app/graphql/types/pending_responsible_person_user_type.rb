module Types
  class PendingResponsiblePersonUserType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: true
    field :email_address, String, null: true, camelize: false
    field :created_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the pending user was created"
    field :updated_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the pending user was last updated"
    field :responsible_person_id, ID, null: true, camelize: false, description: "The ID of the associated notification"
    field :responsible_person, ResponsiblePersonType, null: true, camelize: false, description: "The associated responsible person"
    field :invitation_token, String, null: true, camelize: false
    field :invitation_token_expires_at, Types::CustomDateTimeType, null: true, camelize: false
    field :inviting_user_id, ID, null: true, camelize: false, description: "The ID of the user who sent the invitation"
    field :inviting_user, UserType, null: true, camelize: false, description: "The user who sent the invitation"
  end
end
