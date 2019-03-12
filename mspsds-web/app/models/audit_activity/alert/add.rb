class AuditActivity::Alert::Add < AuditActivity::Base
  extend ActionView::Helpers::NumberHelper
  belongs_to :investigation

  def self.from(alert)
    self.create(
      title: "Product safety alert sent",
      body: build_body(alert),
      source: UserSource.new(user: User.current),
      investigation: alert.investigation
    )
  end

  def self.build_body(alert)
    [
        "From: **Office for Product Safety and Standards**",
        "To: **All users** (#{number_with_delimiter(User.all.length, delimiter: ',')} people)",
        "Subject: **#{alert.summary}**",
        "Date sent: **#{alert.created_at.strftime('%d/%m/%Y')}**",
        "",
        alert.description
    ].join("<br>")
  end
end
