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
end
