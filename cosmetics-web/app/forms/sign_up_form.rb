class SignUpForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include EmailFormValidation

  attribute :name
  attribute :mobile_number
  attribute :password
  attribute :password_confirmation
  validates_presence_of :password, message: "Enter your password"
  validates_presence_of :name, message: "Enter your name"
  validates_presence_of :mobile_number, message: "Enter your mobile number"
end
