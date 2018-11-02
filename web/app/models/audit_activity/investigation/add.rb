class AuditActivity::Investigation::Add < AuditActivity::Investigation
  def self.from(investigation)
    super(investigation, "Case created")
  end

  def subtitle_slug
    nil
  end
end
