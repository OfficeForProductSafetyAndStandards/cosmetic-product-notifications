class ResponsiblePerson < ApplicationRecord
  has_many :notifications, dependent: :destroy
  has_many :team_members, dependent: :destroy
  has_many :users, through: :team_members

  enum account_type: { business: "business", individual: "individual" }

  validates :account_type, presence: true
  validates :email_address, uniqueness: true

  validates :companies_house_number, presence: true, uniqueness: true, on: %i[enter_details create], if: -> { business? }
  validates :name, presence: true, on: %i[enter_details create]
  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, on: %i[enter_details create]
  validates :phone_number, presence: true, on: %i[enter_details create]
  validates :address_line_1, presence: true, on: %i[enter_details create]
  validates :city, presence: true, on: %i[enter_details create]
  validates :postal_code, presence: true, on: %i[enter_details create]

  def add_team_member(user)
    team_members << TeamMember.create(user: user)
  end

  def address_lines
    [address_line_1, address_line_2, city, county, postal_code].select(&:present?)
  end
end
