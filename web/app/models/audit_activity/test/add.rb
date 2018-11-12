class AuditActivity::Test::Add < AuditActivity::Test::Base
  def self.from(test, investigation)
    super(test, investigation)
  end

  def subtitle_slug
    "Testing requested"
  end
end
