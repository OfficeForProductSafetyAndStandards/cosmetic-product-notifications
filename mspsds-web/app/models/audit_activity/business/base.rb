class AuditActivity::Business::Base < AuditActivity::Base
  belongs_to :business

  private_class_method def self.from(business, investigation, title, body)
    self.create(
      body: body,
      source: UserSource.new(user: User.current),
      investigation: investigation,
      title: title,
      business: business
    )
  end
end
