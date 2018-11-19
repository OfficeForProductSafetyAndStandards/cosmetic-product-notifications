class AuditActivity::Test::Request < AuditActivity::Test::Base
  def self.from(test, investigation)
    title = "Test requested: #{test.product.name}"
    super(test, investigation, title)
  end

  def self.date_label
    "Date requested"
  end

  def subtitle_slug
    "Testing requested"
  end
end
