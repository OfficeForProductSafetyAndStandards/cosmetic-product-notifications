class AuditActivity::Report::Base < AuditActivity::Base

  private_class_method def self.from(reporter, investigation)
    self.create(
      body: "Name: **#{reporter.name}** \s\s
             Phone number: **#{reporter.phone_number}** \s\s
             Email address: **#{reporter.email_address}**",
      source: UserSource.new(user: current_user),
      investigation: investigation,
      title: investigation.is_case ? "#{reporter.reporter_type} report" : "",
    )
  end
end
