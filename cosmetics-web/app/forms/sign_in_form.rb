class SignInForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include EmailFormValidation

  attribute :password
  validates_presence_of :password, message: I18n.t(:blank, scope: "sign_in_form.password")
end
