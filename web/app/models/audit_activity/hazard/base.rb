class AuditActivity::Hazard::Base < AuditActivity::Base
  private_class_method def self.from(hazard, investigation)
    body = self.build_body(hazard)
    self.create(
       body: "body",
       source: UserSource.new(user: current_user),
       investigation: investigation,
       title: hazard.hazard_type,
       )
  end
end
