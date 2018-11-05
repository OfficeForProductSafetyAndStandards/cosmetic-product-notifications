class AuditActivity::Hazard < AuditActivity
  private_class_method def self.from(hazard, investigation)
     body = self.build_body(hazard)
     self.create(
         body: body,
         source: UserSource.new(user: current_user),
         investigation: investigation,
         title: hazard.hazard_type,
         )
   end

  def self.build_body(hazard)
    "#{hazard.description} <br><br>
    Risk level: **#{hazard.risk_level}** <br>
    Vulnerable group: **#{hazard.affected_parties}** <br>"
  end
end
