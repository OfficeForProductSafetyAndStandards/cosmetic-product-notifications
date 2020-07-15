class SignInForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include EmailFormValidation

  attribute :password
  validates_presence_of :password, message: "Enter your password"
end
