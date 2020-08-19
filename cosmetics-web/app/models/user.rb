class User < ApplicationRecord
  attribute :old_password, :string

  validates :mobile_number, presence: true
end
