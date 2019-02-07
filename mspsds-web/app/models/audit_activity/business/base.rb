class AuditActivity::Business::Base < AuditActivity::Base
  belongs_to :business

  private_class_method def self.from(business, investigation, title, body)
    activity = self.new(
      body: body,
      source: UserSource.new(user: current_user),
      investigation: investigation,
      title: title,
      business: business
    )
    activity.notify_relevant_users
    activity.save
  end
end
