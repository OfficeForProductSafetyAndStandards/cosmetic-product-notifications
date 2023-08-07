class InviteSupportUserForm < Form
  include StripWhitespace

  attribute :name

  attribute :email

  validates :email,
            email: {
              message: I18n.t(:wrong_format_gov_uk, scope: :email_form_validation),
              if: ->(form) { form.email.present? },
            }
  validates_presence_of :email, message: I18n.t(:blank, scope: :email_form_validation)
  validates_presence_of :name
  validates :name, length: { maximum: User::NAME_MAX_LENGTH }, user_name_format: { message: :invalid }
end
