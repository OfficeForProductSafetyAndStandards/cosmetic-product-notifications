module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :mobile_number, String, null: true, camelize: false
    field :mobile_number_verified, Boolean, null: false, camelize: false
    field :name, String, null: false
    field :email, String, null: false
    field :role, String, null: true
    field :has_accepted_declaration, Boolean, null: false, camelize: false, description: "Indicates whether the user has accepted the declaration"
    field :last_sign_in_at, Types::CustomDateTimeType, null: true, camelize: false, description: "The date and time of the user's last sign-in"
    field :sign_in_count, Integer, null: false, camelize: false, description: "The number of times the user has signed in"
    field :type, String, null: true, description: "The type of the user (could be used for STI)"
    field :locked_at, Types::CustomDateTimeType, null: true, camelize: false, description: "The date and time when the user's account was locked"
    field :created_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the user was created"
    field :updated_at, Types::CustomDateTimeType, null: false, camelize: false, description: "The date and time when the user was last updated"
    field :account_security_completed, Boolean, null: true, camelize: false, description: "Indicates whether the user has completed account security"
    field :deactivated_at, Types::CustomDateTimeType, null: true, camelize: false, description: "The date and time when the user was deactivated"
    field :responsible_persons, [ResponsiblePersonType], null: true, camelize: false, description: "The responsible persons associated with the user"
  end
end
