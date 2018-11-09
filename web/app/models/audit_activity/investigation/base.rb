class AuditActivity::Investigation::Base < AuditActivity::Base
  private_class_method def self.from(investigation, title, body = investigation.description) # rubocop:disable Lint/UselessAccessModifier
    self.create(
      source: UserSource.new(user: current_user),
        investigation: investigation,
        title: title,
        body: body
    )
  end
end
