class Alert < ApplicationRecord
  include Searchable
  include Documentable

  attr_accessor :investigation_url

  belongs_to :investigation

  has_one :source, as: :sourceable, dependent: :destroy

  validate :summary_validation
  validate :description_validation

  after_save :create_audit_activity

  after_save :send_alert_email

  def send_alert_email
    emails = User.all.map(&:email)
    SendAlertJob.perform_later(emails, subject_text: summary, body_text: description)
  end

  def create_audit_activity
    AuditActivity::Alert::Add.from self
  end

  def summary_validation
    if summary.empty? || summary == default_summary
      errors.add(:summary, :required)
    end
  end

  def description_validation
    if description.empty? || description == default_description
      errors.add(:description, :required)
    end
  end

  def default_summary
    "Product safety alert: "
  end

  def default_description
    "\r\n\r\n\r\nMore details can be found on the case page: #{investigation_url}"
  end
end
