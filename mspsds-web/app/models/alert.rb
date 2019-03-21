class Alert < ApplicationRecord
  include Searchable
  include Documentable

  belongs_to :investigation

  has_one :source, as: :sourceable, dependent: :destroy

  validates_presence_of :summary, message: "Enter the alert subject"
  validates_presence_of :description, message: "Enter the alert description"

  after_save :create_audit_activity

  after_save :send_alert_email

  def send_alert_email
    users_details = User.all.map { |user| { full_name: user.full_name, email: user.email } }
    SendAlertJob.perform_later(users_details, summary, description)
  end

  def create_audit_activity
    AuditActivity::Alert::Add.from self
  end
end
