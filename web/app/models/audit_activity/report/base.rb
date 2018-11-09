class AuditActivity::Report::Base < AuditActivity::Base
  private_class_method def self.from(reporter, investigation)
    self.create(
      body: self.build_body(reporter),
      source: UserSource.new(user: current_user),
      investigation: investigation,
      title: investigation.is_case ? "#{reporter.reporter_type} report" : "#{reporter.reporter_type} question",
    )
  end

  def self.build_body(reporter)
    body = ""
    body += "Name: **#{reporter.name}**<br>" if reporter.name.present?
    body += "Phone number: **#{reporter.phone_number}**<br>" if reporter.phone_number.present?
    body += "Email address: **#{reporter.email_address}** \n\n" if reporter.email_address.present?
    body += reporter.other_details.to_s if reporter.other_details.present?
    body
  end
end
