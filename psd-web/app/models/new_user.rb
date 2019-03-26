class NewUser
  include ActiveModel::Model

  attr_accessor :email_address

  validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP }
end
