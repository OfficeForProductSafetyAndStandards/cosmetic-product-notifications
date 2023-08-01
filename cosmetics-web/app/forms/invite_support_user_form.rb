class InviteSupportUserForm < Form
  include StripWhitespace
  include EmailFormValidation

  attribute :name

  validates_presence_of :name
  validates :name, length: { maximum: User::NAME_MAX_LENGTH }, user_name_format: { message: :invalid }
end
