class AuditActivity::Test::Request < AuditActivity::Test::Base
  def self.from(test)
    title = "Test requested: #{test.product.name}"
    super(test, title)
  end

  def self.date_label
    "Date requested"
  end

  def subtitle_slug
    "Testing requested"
  end

  def email_update_text
    "Test request was added to the #{investigation.case_type} by #{source&.show&.titleize}."
  end
end
