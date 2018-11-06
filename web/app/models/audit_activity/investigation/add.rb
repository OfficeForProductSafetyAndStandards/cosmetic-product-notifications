class AuditActivity::Investigation::Add < AuditActivity::Investigation::Base
  def self.from(investigation)
    super(investigation, "Case created")
  end

  def subtitle_slug
    nil
  end
end
