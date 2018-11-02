class AuditActivity::Business::Add < AuditActivity::Business
  def self.from(business, investigation)
    super(business, investigation)
  end

  def subtitle_slug
    "Business added"
  end
end
