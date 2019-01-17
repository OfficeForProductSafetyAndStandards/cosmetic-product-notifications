class AuditActivity::Investigation::UpdateVisibility < AuditActivity::Investigation::Base
  def self.from(investigation)
    title = "#{investigation.case_type.titleize} visibility
            #{investigation.is_private ? 'Restricted' : 'Expanded'}"
    super(investigation, title, investigation.pretty_visibility)
  end
end
