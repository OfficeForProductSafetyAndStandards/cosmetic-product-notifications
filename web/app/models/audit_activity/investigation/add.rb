class AuditActivity::Investigation::Add < AuditActivity::Investigation::Base
  def self.from(investigation)
    super(investigation, "Case created")
  end
end
