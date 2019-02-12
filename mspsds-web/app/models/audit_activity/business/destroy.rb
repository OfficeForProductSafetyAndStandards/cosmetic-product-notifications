class AuditActivity::Business::Destroy < AuditActivity::Business::Base
  def self.from(business, investigation)
    title = "Removed: #{self.sanitize_text business.trading_name}"
    super(business, investigation, title, nil)
  end

  def subtitle_slug
    "Business removed"
  end

  def email_update_text
    "Business was removed from the #{investigation.case_type} by #{source&.show&.titleize}."
  end
end
