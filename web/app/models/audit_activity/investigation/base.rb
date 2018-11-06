class AuditActivity::Investigation::Base < AuditActivity::Base
  private_class_method def self.from(investigation, title) # rubocop:disable Lint/UselessAccessModifier
    self.create(
      source: UserSource.new(user: current_user),
        investigation: investigation,
        title: title,
    )
  end
end
