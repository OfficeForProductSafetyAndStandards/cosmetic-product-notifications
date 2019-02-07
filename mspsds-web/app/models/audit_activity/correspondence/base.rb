class AuditActivity::Correspondence::Base < AuditActivity::Base
  belongs_to :correspondence

  private_class_method def self.from(correspondence, investigation, body = nil)
    activity = self.new(
      body: body || self.sanitize_text(correspondence.details),
      source: UserSource.new(user: current_user),
      investigation: investigation,
      title: correspondence.overview,
      correspondence: correspondence
    )
    activity.notify_relevant_users
    activity.save
  end

  def sensitive_body?
    !correspondence.can_be_displayed?
  end
end
