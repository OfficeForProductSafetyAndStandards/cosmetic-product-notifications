class AuditActivity::Business::Destroy < AuditActivity::Business::Base
  def self.from(business, investigation)
    title = "Removed: #{self.sanitize_text business.trading_name}"
    super(business, investigation, title, nil)
  end

  def subtitle_slug
    "Business removed"
  end
end
