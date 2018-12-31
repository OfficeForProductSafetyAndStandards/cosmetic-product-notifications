class AuditActivity::Test::Base < AuditActivity::Base
  include ActivityAttachable
  with_attachments attachment: "attachment"

  belongs_to :product

  private_class_method def self.from(test, title)
    activity = self.create(
      body: self.build_body(self.sanitize_object test),
      title: title,
      source: UserSource.new(user: current_user),
      investigation: test.investigation,
      product: test.product
    )
    activity.attach_blob test.documents.first.blob if test.documents.attached?
  end

  def self.build_body(test)
    body = ""
    body += "Legislation: **#{test.legislation}**<br>" if test.legislation.present?
    body += "#{date_label}: **#{test.date.strftime('%d/%m/%Y')}**<br>" if test.date.present?
    body += "Attached: **#{test.documents.first.escaped_filename}**<br>" if test.documents.attached?
    body += "<br>#{test.details}" if test.details.present?
    body
  end

  def self.date_label; end
end
