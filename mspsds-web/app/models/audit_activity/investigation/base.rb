class AuditActivity::Investigation::Base < AuditActivity::Base
  private_class_method def self.from(investigation, title, body = nil)
    activity = self.new(
      source: UserSource.new(user: current_user),
      investigation: investigation,
      title: title,
      body: body
    )
    activity.notify_relevant_users
    activity.save
  end
end
