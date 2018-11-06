class AuditActivity::Report::Add < AuditActivity::Report::Base
  def self.from(reporter, investigation)
    super(reporter, investigation)
  end

  def subtitle_slug
    "Report added"
  end
end
