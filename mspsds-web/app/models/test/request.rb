class Test::Request < Test
  after_create :create_audit_activity

  def create_audit_activity
    AuditActivity::Test::Request.from(self)
  end

  def pretty_name
    "testing request"
  end

  validates :date, presence: { message: "Enter date of the test request" }

  def missing_date_component_message
    "Enter date of the test request and include a day, month and year"
  end

  def invalid_date_message
    "Enter a real date of the test request"
  end

  def requested?
    true
  end
end
