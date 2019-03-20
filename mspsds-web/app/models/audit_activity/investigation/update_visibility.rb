class AuditActivity::Investigation::UpdateVisibility < AuditActivity::Investigation::Base
  def self.from(investigation)
    title = "#{investigation.case_type.titleize} visibility
            #{investigation.is_private ? 'Restricted' : 'Unrestricted'}"
    super(investigation, title, self.sanitize_text(investigation.visibility_rationale))
  end

  def email_update_text
    "#{investigation.case_type.titleize} visibility was #{investigation.is_private ? 'restricted' : 'unrestricted'} by #{source&.show&.titleize}."
  end
end
