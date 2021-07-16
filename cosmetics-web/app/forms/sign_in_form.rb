class SignInForm < Form
  include EmailFormValidation

  attribute :password
  validates_presence_of :password
end
