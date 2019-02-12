class Test::Result < Test
  after_create :create_audit_activity

  validates :result, presence: { message: "Select result of the test" }
  validate :result_file_attached

  enum result: { passed: "Pass", failed: "Fail", other: "Other" }

  def create_audit_activity
    AuditActivity::Test::Result.from(self)
  end

  def pretty_name
    "test result"
  end

  def requested?
    false
  end

private

  def result_file_attached
    if documents.attachments.empty?
      errors.add(:base, :file_missing, message: "Provide the test results file")
    end
  end
end
