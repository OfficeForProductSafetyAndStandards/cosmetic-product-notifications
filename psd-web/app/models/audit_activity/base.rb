class AuditActivity::Base < Activity
  def activity_type
    # where necessary should be implemented by subclasses
    "activity"
  end
end
