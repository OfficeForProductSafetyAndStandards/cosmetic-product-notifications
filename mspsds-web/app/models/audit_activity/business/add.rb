class AuditActivity::Business::Add < AuditActivity::Business::Base
  def self.from(business, investigation)
    title = business.trading_name
    relationship = investigation.investigation_businesses.find_by(business_id: business.id).relationship
    body = "Role: **#{self.sanitize_text relationship.titleize}**"
    super(business, investigation, title, body)
  end

  def subtitle_slug
    "Business added"
  end

  def email_update_text
    "Business was added to the #{investigation.case_type} by #{source&.show&.titleize}."
  end
end
