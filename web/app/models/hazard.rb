class Hazard < ApplicationRecord
  belongs_to :investigation
  has_one_attached :risk_assessment
  enum risk_level: %i[none low medium serious severe], _suffix: true

  attribute :set_risk_level

  after_create :add_hazard_audit_activity
  after_update :update_hazard_audit_activity

  def add_hazard_audit_activity
    AuditActivity::Hazard::Add.from(self, self.investigation)
  end

  def update_hazard_audit_activity
    AuditActivity::Hazard::Update.from(self, self.investigation)
  end
end
