class AuditActivity::Investigation::UpdateVisibility < AuditActivity::Investigation::Base
  def self.from(investigation)
    title = "#{investigation.case_type.titleize} visibility
            #{investigation.is_private ? 'Restricted' : 'Unrestricted'}"
    super(investigation, title, investigation.visibility_rationale)
  end
end
