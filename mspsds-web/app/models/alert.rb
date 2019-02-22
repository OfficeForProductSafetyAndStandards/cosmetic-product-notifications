class Alert < ApplicationRecord
  include Searchable
  include Documentable

  belongs_to :investigation

  validates :summary, presence: true

  after_save :create_audit_activity

  def create_audit_activity
    AuditActivity::Alert::Add.from self
  end
end
