class Alert < ApplicationRecord
  include Searchable
  include Documentable

  belongs_to :investigation

  has_one :source, as: :sourceable, dependent: :destroy

  validates :summary, presence: true
  validates :description, presence: true

  after_save :create_audit_activity

  after_save :send_alert_email

  def send_alert_email
    AlertMailer.alert(
      self.source.user.full_name,
      self.source.user.email,
      description,
      summary
    ).deliver_later
  end

  def users_to_notify
  end

  def create_audit_activity
    AuditActivity::Alert::Add.from self
  end
end
