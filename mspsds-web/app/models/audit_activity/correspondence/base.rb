class AuditActivity::Correspondence::Base < AuditActivity::Base
  belongs_to :correspondence

  private_class_method def self.from(correspondence, investigation, body = nil)
    self.create(
      body: body || self.sanitize_text(correspondence.details),
      source: UserSource.new(user: current_user),
      investigation: investigation,
      title: correspondence.overview,
      correspondence: correspondence
    )
  end

  def sensitive_body?
    !correspondence.can_be_displayed?
  end

  def safe_body
    safe_part = "Consumer contact details hidden to comply with GDPR legislation. <br><br>"
    safe_part += "Contact #{source&.user&.organisation&.name || source&.user&.full_name}"
    safe_part += ", who created this case, to obtain these details if required."
    safe_part
  end
end
