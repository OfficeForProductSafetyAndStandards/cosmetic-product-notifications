class ResponsiblePerson < ApplicationRecord
  include StripWhitespace

  has_paper_trail

  ADDRESS_FIELDS = %i[address_line_1 address_line_2 city county postal_code].freeze
  NAME_MAX_LENGTH = 250

  has_many :notifications, dependent: :destroy
  has_many :responsible_person_users, dependent: :destroy
  has_many :pending_responsible_person_users, dependent: :destroy
  has_many :users, through: :responsible_person_users
  has_many :contact_persons, dependent: :destroy
  has_many :address_logs,
           class_name: :ResponsiblePersonAddressLog,
           inverse_of: :responsible_person,
           dependent: :destroy

  has_many :nanomaterial_notifications, dependent: :destroy

  enum account_type: { business: "business", individual: "individual" }

  validates :account_type, presence: true

  with_options on: %i[enter_details create update] do |rp|
    rp.validates :name, presence: true
    rp.validates :address_line_1, presence: true
    rp.validates :city, presence: true
    rp.validates :postal_code, presence: true
    rp.validates :postal_code, uk_postcode: true, if: -> { postal_code.present? }
  end

  validates :name, length: { maximum: NAME_MAX_LENGTH },
                   responsible_person_name_format: true,
                   if: :name_changed?

  def add_user(user)
    responsible_person_users << ResponsiblePersonUser.create(user:)
  end

  def address_lines
    ADDRESS_FIELDS.map { |field| public_send(field) }.select(&:present?)
  end

  def has_user_with_email?(email)
    responsible_person_users.any? { |user| user.email_address.casecmp(email)&.zero? }
  end
end
