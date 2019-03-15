class AuditActivity::Investigation::AddProject < AuditActivity::Investigation::Add
  def self.from(investigation)
    super(investigation, self.build_title(investigation), self.build_body(investigation))
  end

  def self.build_title(investigation)
    "Project logged: #{investigation.title}"
  end

  def self.build_body(investigation)
    body =  "**Project details**<br><br>"
    body += (self.sanitize_text investigation.description).to_s if investigation.description.present?
    body
  end

  def sensitive?
    false
  end
end
