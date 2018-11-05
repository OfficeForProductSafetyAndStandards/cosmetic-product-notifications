class AuditActivity::Investigation < AuditActivity
  private_class_method def self.from(investigation, title) # rubocop:disable Lint/UselessAccessModifier
    self.create(
      source: UserSource.new(user: current_user),
        investigation: investigation,
        title: title,
        body: investigation.description
    )
  end
end
