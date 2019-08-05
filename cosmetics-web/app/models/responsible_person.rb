class ResponsiblePerson < ApplicationRecord
  has_many :notifications, dependent: :destroy
  has_many :notification_files, dependent: :destroy
  has_many :responsible_person_users, dependent: :destroy
  has_many :pending_responsible_person_users, dependent: :destroy
  has_many :users, through: :responsible_person_users
  has_many :contact_persons, dependent: :destroy

  enum account_type: { business: "business", individual: "individual" }

  validates :account_type, presence: true

  validates :name, presence: true, on: %i[enter_details create]
  validates :address_line_1, presence: true, on: %i[enter_details create]
  validates :city, presence: true, on: %i[enter_details create]
  validates :postal_code, presence: true, on: %i[enter_details create]

  def add_user(user)
    responsible_person_users << ResponsiblePersonUser.create(user: user)
  end

  def address_lines
    [address_line_1, address_line_2, city, county, postal_code].select(&:present?)
  end
end
