class AuditActivity::Test::Base < AuditActivity::Base
  include ActivityAttachable

  belongs_to :test
  belongs_to :product

  private_class_method def self.from(test, investigation, title)
    activity = self.create(
      body: self.build_body(test),
      title: title,
      source: UserSource.new(user: current_user),
      investigation: investigation,
      product: test.product,
      test: test
    )
    attach_to_activity(activity, test.documents.first) if test.documents.attached?
  end

  def self.build_body(test)
    date_label = test.requested? ? "Date requested" : "Test date"
    body = ""
    body += "Legislation: **#{test.legislation}**<br>" if test.legislation.present?
    body += "#{date_label}: **#{test.date.strftime('%d/%m/%Y')}**<br>" if test.date.present?
    body += "Attached: **#{test.documents.first.filename}**<br>" if test.documents.attached?
    body += "<br>#{test.details}" if test.details.present?
    body
  end
end
