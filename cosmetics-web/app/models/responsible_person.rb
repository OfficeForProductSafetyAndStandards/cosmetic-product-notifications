class ResponsiblePerson < ApplicationRecord
  include StripWhitespace

  has_many :notifications, dependent: :destroy
  has_many :notification_files, dependent: :destroy
  has_many :responsible_person_users, dependent: :destroy
  has_many :pending_responsible_person_users, dependent: :destroy
  has_many :users, through: :responsible_person_users
  has_many :contact_persons, dependent: :destroy

  has_many :nanomaterial_notifications, dependent: :destroy

  enum account_type: { business: "business", individual: "individual" }

  validates :account_type, presence: true

  with_options on: %i[enter_details create] do |rp|
    rp.validates :name, presence: true
    rp.validates :address_line_1, presence: true
    rp.validates :city, presence: true
    rp.validates :postal_code, presence: true
    rp.validates :postal_code, uk_postcode: true, if: -> { postal_code.present? }
  end

  def add_user(user)
    responsible_person_users << ResponsiblePersonUser.create(user: user)
  end

  def address_lines
    [address_line_1, address_line_2, city, county, postal_code].select(&:present?)
  end

  def has_user_with_email?(email)
    responsible_person_users.any? { |user| user.email_address.casecmp(email)&.zero? }
  end
end
