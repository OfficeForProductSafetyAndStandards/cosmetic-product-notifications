class Test::Request < Test
  after_create :create_audit_activity

  def create_audit_activity
    AuditActivity::Test::Request.from(self)
  end

  def pretty_name
    "testing request"
  end

  def requested?
    true
  end
end
