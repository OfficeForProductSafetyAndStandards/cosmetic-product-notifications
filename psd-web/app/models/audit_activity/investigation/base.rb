class AuditActivity::Investigation::Base < AuditActivity::Base
  private_class_method def self.from(investigation, title, body = nil)
    self.create(
      source: UserSource.new(user: User.current),
      investigation: investigation,
      title: title,
      body: body
    )
  end
end
