class AuditActivity::Investigation::Add < AuditActivity::Investigation::Base
  def self.from(investigation)
    super(investigation, "#{investigation.is_case ? 'Case' : 'Question'} created", investigation.description)
  end
end
