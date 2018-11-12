class AuditActivity::Test::Base < AuditActivity::Base
  include ActivityAttachable

  belongs_to :test
  belongs_to :product

  private_class_method def self.from(test, investigation)
    body = self.build_body(test)
    title = self.build_title(test)
    activity = self.create(
      body: body,
      title: title,
      source: UserSource.new(user: current_user),
      investigation: investigation,
      product: test.product,
      test: test
    )
    attach_to_activity(activity, test.documents.first) if test.documents.attached?
  end

private

  def self.build_title(test)
    "Test requested: #{test.product.name}"
  end

  def self.build_body(test)
    body = ""
    body += "Legislation: **#{test.legislation}**<br>" if test.legislation.present?
    body += "Date requested: **#{test.date.strftime('%d/%m/%Y')}**<br>" if test.date.present?
    body += "Attached: **#{test.documents.first.filename}**<br>" if test.documents.attached?
    body += "<br>#{test.details}" if test.details.present?
    body
  end
end
