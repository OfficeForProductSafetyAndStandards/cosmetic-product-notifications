class Test::Result < Test
  after_create :create_audit_activity

  validates :result, presence: true

  def create_audit_activity
    AuditActivity::Test::Result.from(self, self.investigation)
  end

  def pretty_name
    "test result"
  end
end
