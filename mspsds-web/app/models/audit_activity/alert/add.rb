class AuditActivity::Alert::Add < AuditActivity::Base
  belongs_to :alert
  belongs_to :investigation

  def self.from(alert)
    self.create(
      title: "Alert: #{alert.summary}",
      body: alert.description,
      source: UserSource.new(user: current_user),
      investigation: alert.investigation,
      alert: alert
    )
  end
end
