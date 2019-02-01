class ResponsiblePerson < ApplicationRecord
  has_many :notifications, dependent: :destroy
  has_many :team_members, dependent: :destroy
  has_many :users, through: :team_members

  enum account_type: { business: "business", individual: "individual" }

  validates :account_type, presence: true
  validates :email_address, uniqueness: true

  validates :companies_house_number, presence: true, uniqueness: true, on: :enter_details, if: -> { business? }
  validates :name, presence: true, on: :enter_details
  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, on: :enter_details
  validates :phone_number, presence: true, on: :enter_details
  validates :address_line_1, presence: true, on: :enter_details
  validates :city, presence: true, on: :enter_details
  validates :postal_code, presence: true, on: :enter_details

  def add_team_member(user)
    team_members << TeamMember.create(user: user)
  end
end
