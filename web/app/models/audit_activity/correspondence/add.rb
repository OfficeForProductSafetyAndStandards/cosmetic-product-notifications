class AuditActivity::Correspondence::Add < AuditActivity::Correspondence
  def self.from(correspondence, investigation)
    super(correspondence, investigation)
  end

  def subtitle_slug
    "Correspondence added"
  end
end
