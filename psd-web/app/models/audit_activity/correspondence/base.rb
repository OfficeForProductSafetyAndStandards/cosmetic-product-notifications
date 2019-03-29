class AuditActivity::Correspondence::Base < AuditActivity::Base
  belongs_to :correspondence

  private_class_method def self.from(correspondence, investigation, body = nil)
    self.create(
      body: body || self.sanitize_text(correspondence.details),
      source: UserSource.new(user: User.current),
      investigation: investigation,
      title: correspondence.overview,
      correspondence: correspondence
    )
  end

  def sensitive?
    !correspondence.can_be_displayed?
  end
end
